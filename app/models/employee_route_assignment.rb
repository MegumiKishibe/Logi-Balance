class EmployeeRouteAssignment < ApplicationRecord
  belongs_to :employee
  belongs_to :delivery_route

  validates :employee_id, :delivery_route_id, :effective_from, presence: true
  validate :effective_to_after_effective_from

  private

  def effective_to_after_effective_from
    return if effective_to.blank?
    errors.add(:effective_to, "は開始日以降の日付にしてください") if effective_to < effective_from
  end
end
