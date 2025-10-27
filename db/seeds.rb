# db/seeds.rb
puts "🌱 Seeding database..."

# --- Employees ---
Employee.destroy_all
Employee.create!([
  { employee_no: 1001, name: "山田 太郎", hired_on: "2022-04-01" },
  { employee_no: 1002, name: "佐藤 花子", hired_on: "2023-02-15" },
  { employee_no: 1003, name: "鈴木 次郎", hired_on: "2024-01-10" },
  { employee_no: 1004, name: "高橋 美咲", hired_on: "2021-11-20" },
  { employee_no: 1005, name: "伊藤 健一", hired_on: "2020-06-30" },
  { employee_no: 1006, name: "中村 玲奈", hired_on: "2023-08-05" },
  { employee_no: 1007, name: "小林 大輔", hired_on: "2019-09-12" }
])

# --- Courses ---
Course.destroy_all
Course.create!([
  { name: "Aコース" },
  { name: "Bコース" },
  { name: "Cコース" },
  { name: "Dコース" },
  { name: "Eコース" },
  { name: "Fコース" },
  { name: "Gコース" }
])

# --- Destinations ---
Destination.destroy_all
Destination.create!([
  { name: "スズキアリーナ神殿", address: "奈良県奈良市○○1-1-1" },
  { name: "イエローハット奈良", address: "奈良県奈良市△△2-2-2" },
  { name: "○○中古自動車販売店", address: "奈良県奈良市□□3-3-3" },
  { name: "△△カーディーラー", address: "奈良県奈良市☆☆4-4-4" },
  { name: "□□オートサービス", address: "奈良県奈良市◆◆5-5-5" },
  { name: "☆☆モーターズ", address: "奈良県奈良市■■6-6-6" },
  { name: "◆◆カーショップ", address: "奈良県奈良市★★7-7-7" },
  { name: "■■オートセンター", address: "奈良県奈良市%%8-8-8" }
])

# --- Deliveries ---
Delivery.destroy_all
Delivery.create!([
  {
    employee_id: Employee.first.id,
    course_id: Course.first.id,
    service_date: Date.today,
    started_at: Time.now - 2.hours,
    finished_at: Time.now,
    odo_start_km: 10000,
    odo_end_km: 10050
  }
])

# --- Delivery Stops ---
DeliveryStop.destroy_all
DeliveryStop.create!([
  {
    delivery_id: Delivery.first.id,
    destination_id: Destination.first.id,
    stop_no: 1,
    packages_count: 3,
    pieces_count: 12,
    completed_at: Time.now - 1.hour
  },
  {
    delivery_id: Delivery.first.id,
    destination_id: Destination.second.id,
    stop_no: 2,
    packages_count: 2,
    pieces_count: 8,
    completed_at: Time.now - 30.minutes
  },
  {
    delivery_id: Delivery.first.id,
    destination_id: Destination.third.id,
    stop_no: 3,
    packages_count: 4,
    pieces_count: 15,
    completed_at: Time.now - 10.minutes
  },
  {    delivery_id: Delivery.first.id,
    destination_id: Destination.fourth.id,
    stop_no: 4,
    packages_count: 1,
    pieces_count: 5,
    completed_at: Time.now - 5.minutes
  }
])

puts "✅ Done!"
