class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.integer :employee_no
      t.string :name
      t.date :hired_on

      t.timestamps
    end
  end
end
