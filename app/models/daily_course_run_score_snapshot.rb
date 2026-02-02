class DailyCourseRunScoreSnapshot < ApplicationRecord
  belongs_to :daily_course_run

  def density
    density_score.to_f / 100.0
  end

  validates :work_score, :density_score, :total_score, presence: true
  validates :work_score, :density_score, :total_score,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
