class DailyCourseRunStop < ApplicationRecord
  belongs_to :daily_course_run
  belongs_to :destination

  validates :packages_count, :pieces_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
