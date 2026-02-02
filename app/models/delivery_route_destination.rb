class DeliveryRouteDestination < ApplicationRecord
  belongs_to :delivery_route
  belongs_to :destination

  validates :delivery_route_id, :destination_id, presence: true
  validates :destination_id, uniqueness: { scope: :delivery_route_id }
end
