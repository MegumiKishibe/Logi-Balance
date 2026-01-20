class AddUniqueIndexToCsvImportsFileHash < ActiveRecord::Migration[8.0]
  def change
    add_index :csv_imports, :file_hash, unique: true
  end
end
