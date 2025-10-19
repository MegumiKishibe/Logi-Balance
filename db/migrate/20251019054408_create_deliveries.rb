class CreateDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table :deliveries do |t|
      t.string :destination
      t.string :package
      t.integer :pieces

      t.timestamps
    end
  end
end
