# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_30_132153) do
  create_table "course_destinations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "destination_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_destinations_on_course_id"
    t.index ["destination_id"], name: "index_course_destinations_on_destination_id"
  end

  create_table "courses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "vehicle_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vehicle_type_id"], name: "vehicle_type_id"
  end

  create_table "deliveries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "course_id", null: false
    t.date "service_date"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "odo_start_km"
    t.integer "odo_end_km"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_deliveries_on_course_id"
    t.index ["employee_id"], name: "index_deliveries_on_employee_id"
  end

  create_table "delivery_stops", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "delivery_id", null: false
    t.integer "destination_id"
    t.integer "stop_no"
    t.integer "packages_count"
    t.integer "pieces_count"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_id"], name: "index_delivery_stops_on_delivery_id"
  end

  create_table "destinations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" }, null: false
  end

  create_table "driver_assignments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "course_id", null: false
    t.date "effective_from"
    t.date "effective_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_driver_assignments_on_course_id"
    t.index ["employee_id"], name: "index_driver_assignments_on_employee_id"
  end

  create_table "employees", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "employee_no"
    t.string "last_name_ja", limit: 30, null: false
    t.string "first_name_ja", limit: 30, null: false
    t.string "last_name_en", limit: 30, null: false
    t.string "first_name_en", limit: 30, null: false
    t.date "hired_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "score_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "delivery_id", null: false
    t.integer "work_score"
    t.integer "density_score"
    t.integer "total_score"
    t.datetime "calculated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_id"], name: "index_score_snapshots_on_delivery_id"
  end

  create_table "vehicle_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 20, null: false
  end

  add_foreign_key "course_destinations", "courses"
  add_foreign_key "course_destinations", "destinations"
  add_foreign_key "courses", "vehicle_types", name: "courses_ibfk_1"
  add_foreign_key "deliveries", "courses"
  add_foreign_key "deliveries", "employees"
  add_foreign_key "delivery_stops", "deliveries"
  add_foreign_key "driver_assignments", "courses"
  add_foreign_key "driver_assignments", "employees"
  add_foreign_key "score_snapshots", "deliveries"
end
