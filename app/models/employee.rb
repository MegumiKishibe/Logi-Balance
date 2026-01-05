class Employee < ApplicationRecord
  # Deviseモジュール設定
  devise :database_authenticatable,
         :rememberable,
         authentication_keys: [ :employee_no ]

  has_many :deliveries
  has_many :driver_assignments

  validates :employee_no, presence: true, uniqueness: true
  validates :last_name_ja, :first_name_ja, :last_name_en, :first_name_en, :hired_on, presence: true
end
