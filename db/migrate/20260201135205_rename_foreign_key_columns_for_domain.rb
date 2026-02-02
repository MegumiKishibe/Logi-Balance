class RenameForeignKeyColumnsForDomain < ActiveRecord::Migration[7.1]
  def change
    # delivery_route_destinations は migration の先頭で
    # すでに course_id -> delivery_route_id が成功しており、
    # index名も新名になっているため、ここでは何もしない（安全策）

    # --- daily_course_runs ---
    if column_exists?(:daily_course_runs, :course_id)
      rename_column :daily_course_runs, :course_id, :delivery_route_id
    end
    if index_name_exists?(:daily_course_runs, "index_daily_course_runs_on_course_id")
      rename_index :daily_course_runs,
                   "index_daily_course_runs_on_course_id",
                   "index_daily_course_runs_on_delivery_route_id"
    end

    # --- daily_course_run_stops ---
    if column_exists?(:daily_course_run_stops, :delivery_id)
      rename_column :daily_course_run_stops, :delivery_id, :daily_course_run_id
    end
    if index_name_exists?(:daily_course_run_stops, "index_daily_course_run_stops_on_delivery_id")
      rename_index :daily_course_run_stops,
                   "index_daily_course_run_stops_on_delivery_id",
                   "index_daily_course_run_stops_on_daily_course_run_id"
    end

    # --- employee_route_assignments ---
    if column_exists?(:employee_route_assignments, :course_id)
      rename_column :employee_route_assignments, :course_id, :delivery_route_id
    end
    if index_name_exists?(:employee_route_assignments, "index_employee_route_assignments_on_course_id")
      rename_index :employee_route_assignments,
                   "index_employee_route_assignments_on_course_id",
                   "index_employee_route_assignments_on_delivery_route_id"
    end

    # --- daily_course_run_score_snapshots ---
    if column_exists?(:daily_course_run_score_snapshots, :delivery_id)
      rename_column :daily_course_run_score_snapshots, :delivery_id, :daily_course_run_id
    end
    if index_name_exists?(:daily_course_run_score_snapshots, "index_daily_course_run_score_snapshots_on_delivery_id")
      rename_index :daily_course_run_score_snapshots,
                   "index_daily_course_run_score_snapshots_on_delivery_id",
                   "index_daily_course_run_score_snapshots_on_daily_course_run_id"
    end
  end
end
