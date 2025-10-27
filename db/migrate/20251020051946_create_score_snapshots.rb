class CreateScoreSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :score_snapshots do |t|
      t.references :delivery, null: false, foreign_key: true
      t.integer :work_score
      t.integer :density_score
      t.integer :total_score
      t.datetime :calculated_at

      t.timestamps
    end
  end
end
