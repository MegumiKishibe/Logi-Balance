class Destination < ApplicationRecord
  has_many :daily_course_run_stops, dependent: :restrict_with_error

  has_many :delivery_route_destinations, dependent: :destroy
  has_many :delivery_routes, through: :delivery_route_destinations

  validates :name, :address, presence: true
  validates :address, uniqueness: true
end
