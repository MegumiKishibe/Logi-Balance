class ScoreSnapshotCreator
  def initialize(delivery)
    @delivery = delivery
  end

  def call
    result = ScoreCalculator.new(@delivery).calculate
    # result = { work: Integer, density: Float, total: Integer }
    density_int = (result[:density].to_f * 100).round  # 1.30 -> 130

    ScoreSnapshot.where(delivery_id: @delivery.id).delete_all

    @delivery.score_snapshots.create!(
      work_score: result[:work],
      density_score: density_int,
      total_score: result[:total],
      calculated_at: Time.zone.now
    )

    result
  end
end
