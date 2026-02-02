class ScoreCalculator
  include WorkloadConfig

  def initialize(daily_course_run)
    @daily_course_run = daily_course_run
    @stops = daily_course_run.daily_course_run_stops.where.not(completed_at: nil)
  end

  def calculate
    work = calculate_work
    density = calculate_density
    total = (work * density).round

    {
      work: work.round,
      density: density.round(2),
      total: total
    }
  end

  private

  def calculate_work
    stops_count = @stops.count
    pieces = @stops.sum(:pieces_count)

    (S * stops_count) + (P * pieces)
  end

  def calculate_density
    stops_count = @stops.count
    distance_km = (@daily_course_run.odo_end_km.to_f - @daily_course_run.odo_start_km.to_f)

    # ★ zero division 対策
    km_per_stop =
      if stops_count.zero?
        0
      else
        distance_km / stops_count
      end

    extra = [ km_per_stop - T, 0 ].max
    1 + A * extra
  end
end
