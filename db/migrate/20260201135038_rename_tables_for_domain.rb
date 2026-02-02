class RenameTablesForDomain < ActiveRecord::Migration[7.1]
  def change
    rename_table :course_destinations, :delivery_route_destinations
    rename_table :courses, :delivery_routes
    rename_table :deliveries, :daily_course_runs
    rename_table :delivery_stops, :daily_course_run_stops
    rename_table :driver_assignments, :employee_route_assignments
    rename_table :score_snapshots, :daily_course_run_score_snapshots
  end
end
