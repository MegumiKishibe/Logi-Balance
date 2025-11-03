class CreateCourseDestinations < ActiveRecord::Migration[8.0]
  def change
    create_table :course_destinations do |t|
      t.references :course, null: false, foreign_key: true
      t.references :destination, null: false, foreign_key: true

      t.timestamps
    end
  end
end
