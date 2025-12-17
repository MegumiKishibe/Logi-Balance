# frozen_string_literal: true

class AddDeviseToEmployees < ActiveRecord::Migration[8.0]
  def self.up
    change_table :employees do |t|
      # Recoverable
      # t.string   :reset_password_token
      # t.datetime :reset_password_sent_at

      # Rememberable
      # t.datetime :remember_created_at
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
