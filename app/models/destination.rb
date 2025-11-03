class Destination < ApplicationRecord
  has_many :delivery_stops
  has_many :course_destinations
  has_many :courses, through: :course_destinations

  validates :name, :address, presence: true
  validates :address, uniqueness: true
end
