class ScoreSnapshot < ApplicationRecord
  def density
    density_score.to_f / 100.0
  end

  belongs_to :delivery

  validates :work_score, :density_score, :total_score, presence: true
  validates :work_score, :density_score, :total_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
