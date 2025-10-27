class CreateDeliveryStops < ActiveRecord::Migration[8.0]
  def change
    create_table :delivery_stops do |t|
      t.references :delivery, null: false, foreign_key: true
      t.integer :destination_id
      t.integer :stop_no
      t.integer :packages_count
      t.integer :pieces_count
      t.datetime :completed_at

      t.timestamps
    end
  end
end
