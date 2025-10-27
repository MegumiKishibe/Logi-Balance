class CreateDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table :deliveries do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.date :service_date
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :odo_start_km
      t.integer :odo_end_km

      t.timestamps
    end
  end
end
