class VehicleType < ApplicationRecord
  has_many :delivery_routes, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
