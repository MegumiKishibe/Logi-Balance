class Employee < ApplicationRecord
  has_many :deliveries
  has_many :driver_assignments

  validates :employee_no, presence: true, uniqueness: true
  validates :last_name_ja, presence: true
  validates :first_name_ja, presence: true
  validates :last_name_en, presence: true
  validates :first_name_en, presence: true
  validates :hired_on, presence: true
end
