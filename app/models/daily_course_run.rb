class DailyCourseRun < ApplicationRecord
  belongs_to :employee
  belongs_to :delivery_route

  has_many :daily_course_run_stops, dependent: :destroy
  has_many :daily_course_run_score_snapshots, dependent: :destroy

  # 完了済みだけを一覧/集計対象にしたい
  scope :completed, -> { where.not(finished_at: nil) }

  validates :employee_id, :delivery_route_id, :service_date, :started_at, :odo_start_km, presence: true
  validates :odo_start_km, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # 全て完了した場合のみデータ登録必須
  validates :odo_end_km, presence: true, if: :finished?
  validates :odo_end_km, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  validate :odo_end_km_not_less_than_start

  def finished?
    finished_at.present?
  end

  private

  def odo_end_km_not_less_than_start
    return if odo_end_km.blank?
    return if odo_start_km.blank?
    errors.add(:odo_end_km, "は開始指針以上にしてください") if odo_end_km < odo_start_km
  end
end
