class DeliveryRoute < ApplicationRecord
  belongs_to :vehicle_type

  has_many :employee_route_assignments, dependent: :destroy
  has_many :delivery_route_destinations, dependent: :destroy
  has_many :destinations, through: :delivery_route_destinations

  has_many :daily_course_runs, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :vehicle_type_id, presence: true
end
