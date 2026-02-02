class Employee < ApplicationRecord
  # Deviseモジュール設定
  devise :database_authenticatable,
         :rememberable,
         authentication_keys: [ :employee_no ]

  # 日次コース稼働
  has_many :daily_course_runs, dependent: :nullify

  # ドライバー×ルート割当
  has_many :employee_route_assignments, dependent: :nullify
  has_many :delivery_routes, through: :employee_route_assignments

  validates :employee_no, presence: true, uniqueness: true
  validates :last_name_ja, :first_name_ja, :last_name_en, :first_name_en, :hired_on, presence: true
end
