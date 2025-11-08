class Delivery < ApplicationRecord
  belongs_to :employee
  belongs_to :course
  has_many :delivery_stops
  has_one :score_snapshot

  validates :employee_id, :course_id, :service_date, :started_at, :odo_start_km, :odo_end_km, presence: true
  validates :odo_start_km, :odo_end_km, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
