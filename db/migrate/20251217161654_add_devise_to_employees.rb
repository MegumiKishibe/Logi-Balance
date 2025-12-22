# frozen_string_literal: true

class AddDeviseToEmployees < ActiveRecord::Migration[8.0]
  def change
    change_table :employees, bulk: true do |t|
      # Devise必須
      t.string :encrypted_password, null: false, default: ""

      # Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      # Rememberable
      t.datetime :remember_created_at

      # Trackable（誰がいつログインしたかの記録）
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end

    add_index :employees, :reset_password_token, unique: true
  end
end
