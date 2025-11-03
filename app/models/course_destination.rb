class CourseDestination < ApplicationRecord
  belongs_to :course
  belongs_to :destination

  validates :course_id, :destination_id, presence: true
  validates :destination_id, uniqueness: { scope: :course_id }
end
