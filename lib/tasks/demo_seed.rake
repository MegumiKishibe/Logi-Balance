# lib/tasks/demo_seed.rake
require "csv"

namespace :demo do
  # ==== helpers ==============================================================
  def parse_date!(s)
    Date.parse(s)
  rescue ArgumentError
    raise "Invalid date: #{s.inspect} (use YYYY-MM-DD)"
  end

  # total を n 個に分割（各要素が min..max に入るように）
  def bounded_partition(total, n, min:, max:)
    raise "bad partition: total=#{total}, n=#{n}" if n <= 0
    raise "impossible partition" if total < n * min || total > n * max

    parts = []
    remaining = total
    (1..n).each do |i|
      left = n - i
      min_i = [min, remaining - left * max].max
      max_i = [max, remaining - left * min].min
      v = rand(min_i..max_i)
      parts << v
      remaining -= v
    end
    parts
  end

  # pieces は packages 以上にしたい（各stopで pieces >= packages, pieces<=max）
  def bounded_partition_with_floor(total, floors, max:)
    n = floors.length
    min_sum = floors.sum
    raise "impossible pieces: total < sum(floors)" if total < min_sum
    raise "impossible pieces: total > n*max" if total > n * max

    parts = []
    remaining = total
    (0...n).each do |idx|
      left = n - idx - 1
      floor = floors[idx]
      min_left = floors[(idx + 1)..].sum
      min_i = [floor, remaining - left * max].max
      max_i = [max, remaining - min_left].min
      v = rand(min_i..max_i)
      parts << v
      remaining -= v
    end
    parts
  end

  def add_prefix(prefix, text)
    "#{prefix} #{text}".strip
  end

  # ==== seed =================================================================
  desc "Seed 7 employees + 7 delivery_routes demo data (no prefix by default; safe & re-runnable)"
  task seed_annual: :environment do
    start_date = parse_date!(ENV.fetch("START_DATE", "2024-01-01"))
    end_date   = parse_date!(ENV.fetch("END_DATE",   Date.current.to_s))
    raise "START_DATE must be <= END_DATE" if start_date > end_date

    # ★デフォルトは空（=表示に [DEMO] を付けない）
    prefix = ENV.fetch("DEMO_PREFIX", "").to_s
    password = ENV.fetch("PASSWORD", "testtest")
    employee_no_base = ENV.fetch("EMPLOYEE_NO_BASE", "9001").to_i

    pkg_min = ENV.fetch("PKG_MIN", "20").to_i
    pkg_max = ENV.fetch("PKG_MAX", "50").to_i
    pcs_min = ENV.fetch("PCS_MIN", "20").to_i
    pcs_max = ENV.fetch("PCS_MAX", "100").to_i

    heavy_pkg_range = (pkg_max - 5..pkg_max)
    heavy_pcs_range = ([pcs_max - 10, pcs_min].max..pcs_max)
    light_pkg_range = (pkg_min..[pkg_min + 5, pkg_max].min)
    light_pcs_range = (pcs_min..[pcs_min + 15, pcs_max].min)

    route_specs = [
      { kind: :heavy,  name: "奈良市北部 2tコース" },
      { kind: :heavy,  name: "橿原・大和高田 2tコース" },
      { kind: :light,  name: "生駒 軽バンコース" },
      { kind: :light,  name: "香芝・王寺 軽バンコース" },
      { kind: :random, name: "天理コース" },
      { kind: :random, name: "大和郡山コース" },
      { kind: :random, name: "奈良市中心コース" }
    ]

    puts "==> demo:seed_annual #{start_date}..#{end_date} (#{(end_date - start_date).to_i + 1} days)"
    puts "==> prefix=#{prefix.inspect} (blank = no prefix), employees=7 (#{employee_no_base}..#{employee_no_base + 6})"
    puts "==> daily totals per route: packages #{pkg_min}..#{pkg_max}, pieces #{pcs_min}..#{pcs_max}"

    # VehicleType（共通）
    vt_name = add_prefix(prefix, "2t")
    vt = VehicleType.find_or_create_by!(name: vt_name)

    # Employees 7人
    driver_specs = [
      { last_ja: "山本", first_ja: "航",   last_en: "Yamamoto",  first_en: "Wataru" },
      { last_ja: "田中", first_ja: "陸",   last_en: "Tanaka",    first_en: "Riku" },
      { last_ja: "佐藤", first_ja: "蓮",   last_en: "Sato",      first_en: "Ren" },
      { last_ja: "中村", first_ja: "陽菜", last_en: "Nakamura", first_en: "Hina" },
      { last_ja: "小林", first_ja: "凛",   last_en: "Kobayashi", first_en: "Rin" },
      { last_ja: "加藤", first_ja: "樹",   last_en: "Kato",      first_en: "Itsuki" },
      { last_ja: "吉田", first_ja: "悠",   last_en: "Yoshida",   first_en: "Yu" }
    ]

    employees = driver_specs.each_with_index.map do |spec, i|
      no = employee_no_base + i

      e = Employee.find_or_initialize_by(employee_no: no)
      e.last_name_ja  = spec[:last_ja]
      e.first_name_ja = spec[:first_ja]
      e.last_name_en  = spec[:last_en]
      e.first_name_en = spec[:first_en]
      e.hired_on      = start_date
      e.password      = password
      e.password_confirmation = password

      if Employee.column_names.include?("email")
        e.email = "demo#{no}@example.com" if e.email.blank?
      end

      e.save!
      e
    end

    # DeliveryRoutes 7本（prefixはデフォ空。付けたい人だけ ENV で付ける）
    delivery_routes = route_specs.map do |spec|
      name = add_prefix(prefix, spec[:name])
      DeliveryRoute.find_by(name: name) || DeliveryRoute.create!(name: name, vehicle_type: vt)
    end

    # 配達先プール（ルートごとに40件）
    destination_specs = [
      { cities: ["奈良市"],           towns: %w[法蓮町 大宮町 芝辻町 押熊町 秋篠町 西大寺南町 学園北] },
      { cities: ["橿原市","大和高田市"], towns: %w[内膳町 久米町 葛本町 今井町 神楽 大中] },
      { cities: ["生駒市"],           towns: %w[東生駒 谷田町 元町 俵口町 壱分町 小明町 北新町] },
      { cities: ["香芝市","王寺町"],     towns: %w[下田西 瓦口 真美ヶ丘 旭ヶ丘 久度 本町] },
      { cities: ["天理市"],           towns: %w[川原城町 田部町 別所町 櫟本町 前栽町 嘉幡町] },
      { cities: ["大和郡山市"],        towns: %w[朝日町 高田町 小泉町 九条町 柳町 城町] },
      { cities: ["奈良市"],           towns: %w[高天町 東向中町 三条町 船橋町 今小路町 小西町] }
    ]

    delivery_routes.each_with_index do |route, idx|
      spec = destination_specs[idx]

      40.times do |j|
        city = spec[:cities][j % spec[:cities].length]
        town = spec[:towns][j % spec[:towns].length]
        num  = j + 1

        base_name = "#{city} #{town} 配達先#{format('%03d', num)}"
        name = add_prefix(prefix, base_name)

        base_address = "奈良県#{city}#{town}#{(num % 5) + 1}丁目#{(num % 20) + 1}-#{(num % 10) + 1}"
        # address unique を想定して、衝突したら suffix で必ず回避
        unique_suffix = " R#{format('%02d', idx + 1)}-#{format('%03d', num)}"
        address = base_address
        if Destination.where(address: address).exists?
          address = "#{base_address}#{unique_suffix}"
          # それでも万一被ったら連番で回避（超保険）
          k = 1
          while Destination.where(address: address).exists?
            k += 1
            address = "#{base_address}#{unique_suffix}-#{k}"
          end
        end

        d = Destination.find_or_initialize_by(name: name)
        d.address = address
        d.save!

        DeliveryRouteDestination.find_or_create_by!(delivery_route_id: route.id, destination_id: d.id)
      end
    end

    # 期間分作成（1日=7 runs）
    created_runs = 0
    created_stops = 0
    created_snapshots = 0

    (start_date..end_date).each_with_index do |date, day_idx|
      delivery_routes.each_with_index do |route, ci|
        employee = employees[ci] # ルートと社員を1対1

        started_at = Time.zone.local(date.year, date.month, date.day, 8, 0, 0) + (ci * 10).minutes
        odo_start  = 10_000 + rand(0..5_000)

        run = DailyCourseRun.find_by(employee_id: employee.id, delivery_route_id: route.id, service_date: date)

        if run
          run.daily_course_run_stops.delete_all
          run.daily_course_run_score_snapshots.delete_all
          run.update!(
            started_at: started_at,
            odo_start_km: odo_start,
            odo_end_km: nil,
            finished_at: nil
          )
        else
          run = DailyCourseRun.create!(
            employee_id: employee.id,
            delivery_route_id: route.id,
            service_date: date,
            started_at: started_at,
            odo_start_km: odo_start
          )
          created_runs += 1
        end

        kind = route_specs[ci][:kind]
        packages_total =
          case kind
          when :heavy then rand(heavy_pkg_range)
          when :light then rand(light_pkg_range)
          else rand(pkg_min..pkg_max)
          end

        pieces_total =
          case kind
          when :heavy then rand([heavy_pcs_range.begin, packages_total].max..heavy_pcs_range.end)
          when :light then rand([light_pcs_range.begin, packages_total].max..light_pcs_range.end)
          else rand([pcs_min, packages_total].max..pcs_max)
          end

        min_stops = [
          (packages_total / 10.0).ceil,
          (pieces_total / 20.0).ceil,
          4
        ].max

        stop_count =
          case kind
          when :heavy then [rand(10..18), min_stops].max
          when :light then [rand(6..10),  min_stops].max
          else             [rand(8..14),  min_stops].max
          end

        packages_parts = bounded_partition(packages_total, stop_count, min: 1, max: 10)
        pieces_parts   = bounded_partition_with_floor(pieces_total, packages_parts, max: 20)

        destinations = route.destinations.sample(stop_count)

        t = started_at + 15.minutes
        step_range =
          case kind
          when :heavy then 18..35
          when :light then 10..22
          else 12..28
          end

        destinations.each_with_index do |dest, si|
          run.daily_course_run_stops.create!(
            destination_id: dest.id,
            packages_count: packages_parts[si],
            pieces_count: pieces_parts[si],
            completed_at: t
          )
          created_stops += 1
          t += rand(step_range).minutes
        end

        finished_at = t
        distance_km =
          case kind
          when :heavy then rand(70..140)
          when :light then rand(15..45)
          else rand(30..90)
          end

        run.update!(finished_at: finished_at, odo_end_km: odo_start + distance_km)

        run.daily_course_run_score_snapshots.delete_all if run.daily_course_run_score_snapshots.exists?

        scores = ScoreCalculator.new(run).calculate
        t_snapshot = run.daily_course_run_stops.maximum(:completed_at) || Time.current

        DailyCourseRunScoreSnapshot.create!(
          daily_course_run: run,
          work_score: scores[:work],
          density_score: (scores[:density] * 100).round,
          total_score: scores[:total],
          created_at: t_snapshot,
          updated_at: t_snapshot
        )
        created_snapshots += 1
      end

      puts "  seeded #{date}" if (day_idx % 30).zero?
    end

    puts "==> Done. created_runs=#{created_runs} (existing updated too), created_stops=#{created_stops}, created_snapshots=#{created_snapshots}"
    puts "==> Login: employee_no=#{employee_no_base}..#{employee_no_base + 6}, password=#{password}"
  end
end
