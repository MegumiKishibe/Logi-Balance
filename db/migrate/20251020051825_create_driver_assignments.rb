class CreateDriverAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :driver_assignments do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.date :effective_from
      t.date :effective_to

      t.timestamps
    end
  end
end
