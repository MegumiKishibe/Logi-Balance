class Course < ApplicationRecord
  belongs_to :vehicle_type
  has_many :driver_assignments
  has_many :course_destinations
  has_many :destinations, through: :course_destinations
  has_many :deliveries

  validates :name, presence: true, uniqueness: true
  validates :vehicle_type_id, presence: true
end
