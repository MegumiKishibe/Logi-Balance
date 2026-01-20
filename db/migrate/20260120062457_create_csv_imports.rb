class CreateCsvImports < ActiveRecord::Migration[8.0]
  def change
    create_table :csv_imports do |t|
      t.string :file_hash
      t.string :filename
      t.string :status
      t.text :error_message

      t.timestamps
    end
  end
end
