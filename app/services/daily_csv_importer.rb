require "csv"
require "digest"

class DailyCsvImporter
  EXPECTED_HEADER = [ "日付", "従業員コード", "コース", "開始時刻", "開始指針", "終了指針", "配達先", "住所", "件数", "個数", "完了時間" ].freeze

  def initialize(file)
    @file = file
  end

  def call
    # ================================
    # ① CSV全体ハッシュで二重取り込み防止
    # ================================
    file_hash = sha256(@file)
    if CsvImport.exists?(file_hash: file_hash, status: "success")
      return fail_result("同じCSVはすでに取り込み済みです")
    end

    import = CsvImport.create!(
      file_hash: file_hash,
      filename: original_filename,
      status: "processing"
    )

    text = read_as_utf8(@file)
    rows = CSV.parse(text)
    return fail_result("CSVが空です") if rows.blank?

    header = rows.first&.map { |v| v.to_s.strip }
    return fail_result("ヘッダーが想定と違います。想定: #{EXPECTED_HEADER.join(', ')}") if header != EXPECTED_HEADER

    detail_rows = []
    rows.drop(1).each do |r|
      next if r.nil?
      break if r.compact.map { |v| v.to_s.strip }.all?(&:blank?)
      detail_rows << r
    end
    return fail_result("明細行がありません") if detail_rows.empty?

    first = normalize_row(detail_rows.first)

    date = parse_date(first[:date_str])
    return fail_result("日付が不正です: #{first[:date_str]}") if date.nil?

    employee_code = first[:employee_code].to_s.strip
    return fail_result("従業員コードが空です") if employee_code.blank?

    employee = Employee.find_by(employee_no: employee_code)
    return fail_result("従業員が見つかりません: #{employee_code}") if employee.nil?

    route_name = first[:course_name].to_s.strip
    return fail_result("コース名が空です") if route_name.blank?

    delivery_route = DeliveryRoute.find_by(name: route_name)
    return fail_result("コースが見つかりません: #{route_name}") if delivery_route.nil?

    started_at = build_time(date, first[:start_time_str])
    return fail_result("開始時刻が不正です: #{first[:start_time_str]}") if started_at.nil?

    odo_start = parse_int(first[:odo_start_km])
    odo_end   = parse_int(first[:odo_end_km])

    imported = 0

    ActiveRecord::Base.transaction do
      # ================================
      # ② DailyCourseRun は同日・同コースで1件
      # ================================
      daily_course_run = DailyCourseRun.find_or_initialize_by(
        delivery_route_id: delivery_route.id,
        service_date: date
      )

      daily_course_run.assign_attributes(
        employee_id: employee.id,
        started_at: started_at,
        odo_start_km: odo_start,
        odo_end_km: odo_end
      )
      daily_course_run.save!

      # ================================
      # ③ 後から読み込まれたCSVが勝つ（上書き）
      # ================================
      detail_rows.each do |r|
        row = normalize_row(r)

        raise ActiveRecord::Rollback if parse_date(row[:date_str]) != date
        raise ActiveRecord::Rollback if row[:employee_code].to_s.strip != employee_code
        raise ActiveRecord::Rollback if row[:course_name].to_s.strip != route_name

        address = row[:address].to_s.strip
        next if address.blank?

        # Destination は住所で再利用（名前は初回のみ）
        destination = Destination.find_or_create_by!(address: address) do |d|
          d.name = row[:destination_name].to_s.strip.presence || "(名称なし)"
        end

        # 同日×同コース×同住所 → 1件（後勝ち）
        stop = DailyCourseRunStop.find_or_initialize_by(
          daily_course_run_id: daily_course_run.id,
          destination_id: destination.id
        )

        stop.assign_attributes(
          packages_count: parse_int(row[:packages_count]),
          pieces_count: parse_int(row[:pieces_count]),
          completed_at: build_time(date, row[:completed_time_str])
        )

        stop.save!
        imported += 1
      end

      import.update!(status: "success")
    end

    ok_result(imported: imported, course_name: route_name, date: date)
  rescue ActiveRecord::Rollback
    import&.update(status: "failed")
    fail_result("CSV内で日付/従業員コード/コースが揃っていないか、形式が不正です")
  rescue => e
    import&.update(status: "failed", error_message: e.message)
    fail_result(e.message)
  end

  private

  def sha256(file)
    io = file.tempfile
    io.rewind
    Digest::SHA256.hexdigest(io.read)
  ensure
    io.rewind
  end

  def original_filename
    @file.original_filename
  end

  def normalize_row(r)
    {
      date_str: r[0].to_s.strip,
      employee_code: r[1].to_s.strip,
      course_name: r[2].to_s.strip,
      start_time_str: r[3].to_s.strip,
      odo_start_km: r[4],
      odo_end_km: r[5],
      destination_name: r[6].to_s.strip,
      address: r[7].to_s.strip,
      packages_count: r[8],
      pieces_count: r[9],
      completed_time_str: r[10].to_s.strip
    }
  end

  def parse_date(v)
    return nil if v.blank?
    Date.parse(v.to_s) rescue nil
  end

  def parse_int(v)
    return 0 if v.blank?
    v.to_s.strip.tr(",", "").to_i
  end

  def build_time(date, hhmm)
    return nil if hhmm.blank?
    Time.use_zone("Asia/Tokyo") { Time.zone.parse("#{date} #{hhmm}") }
  rescue
    nil
  end

  def read_as_utf8(file)
    raw = File.binread(file.path)
    raw = raw.byteslice(3..) if raw.bytes[0, 3] == [ 0xEF, 0xBB, 0xBF ]

    begin
      raw.force_encoding("UTF-8").encode("UTF-8")
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
      raw.force_encoding("Windows-31J").encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    end
  end

  def ok_result(imported:, course_name:, date:)
    { ok: true, imported: imported, course_name: course_name, date: date }
  end

  def fail_result(message)
    { ok: false, error: message }
  end
end
