class ScoreSnapshotCreator
  def initialize(daily_course_run)
    @daily_course_run = daily_course_run
  end

  def call
    result = ScoreCalculator.new(@daily_course_run).calculate
    # result = { work: Integer, density: Float, total: Integer }
    density_int = (result[:density].to_f * 100).round # 1.30 -> 130

    DailyCourseRunScoreSnapshot.where(daily_course_run_id: @daily_course_run.id).delete_all

    @daily_course_run.daily_course_run_score_snapshots.create!(
      work_score: result[:work],
      density_score: density_int,
      total_score: result[:total],
      calculated_at: Time.zone.now
    )

    result
  end
end
