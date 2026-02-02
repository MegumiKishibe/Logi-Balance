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

ActiveRecord::Schema[8.0].define(version: 2026_02_01_135205) do
  create_table "csv_imports", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "file_hash"
    t.string "filename"
    t.string "status"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_hash"], name: "index_csv_imports_on_file_hash", unique: true
  end

  create_table "daily_course_run_score_snapshots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "daily_course_run_id", null: false
    t.integer "work_score"
    t.integer "density_score"
    t.integer "total_score"
    t.datetime "calculated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_course_run_id"], name: "index_daily_course_run_score_snapshots_on_daily_course_run_id"
  end

  create_table "daily_course_run_stops", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "daily_course_run_id", null: false
    t.integer "destination_id"
    t.integer "stop_no"
    t.integer "packages_count"
    t.integer "pieces_count"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_course_run_id"], name: "index_daily_course_run_stops_on_daily_course_run_id"
  end

  create_table "daily_course_runs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "delivery_route_id", null: false
    t.date "service_date"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "odo_start_km"
    t.integer "odo_end_km"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_route_id"], name: "index_daily_course_runs_on_delivery_route_id"
    t.index ["employee_id"], name: "index_daily_course_runs_on_employee_id"
  end

  create_table "delivery_route_destinations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "delivery_route_id", null: false
    t.bigint "destination_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_route_id"], name: "index_delivery_route_destinations_on_delivery_route_id"
    t.index ["destination_id"], name: "index_delivery_route_destinations_on_destination_id"
  end

  create_table "delivery_routes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "vehicle_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vehicle_type_id"], name: "vehicle_type_id"
  end

  create_table "destinations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" }, null: false
  end

  create_table "employee_route_assignments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "delivery_route_id", null: false
    t.date "effective_from"
    t.date "effective_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_route_id"], name: "index_employee_route_assignments_on_delivery_route_id"
    t.index ["employee_id"], name: "index_employee_route_assignments_on_employee_id"
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
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
  end

  create_table "vehicle_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 20, null: false
  end

  add_foreign_key "daily_course_run_score_snapshots", "daily_course_runs"
  add_foreign_key "daily_course_run_stops", "daily_course_runs"
  add_foreign_key "daily_course_runs", "delivery_routes"
  add_foreign_key "daily_course_runs", "employees"
  add_foreign_key "delivery_route_destinations", "delivery_routes"
  add_foreign_key "delivery_route_destinations", "destinations"
  add_foreign_key "delivery_routes", "vehicle_types", name: "delivery_routes_ibfk_1"
  add_foreign_key "employee_route_assignments", "delivery_routes"
  add_foreign_key "employee_route_assignments", "employees"
end
