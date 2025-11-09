class DeliveryStop < ApplicationRecord
  belongs_to :delivery
  belongs_to :destination

  # validates :stop_no, presence: true
  validates :packages_count, :pieces_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # validates :completed_at, presence: true
end
