class AnalyticsController < ApplicationController
  def index
    @dates = Delivery.distinct.order(service_date: :desc).pluck(:service_date)

    base = params[:date].presence || @dates.first || Date.current
    @date = base.to_date

    @daily_scores = Delivery
      .joins(:score_snapshots, :course)
      .where(service_date: @date)
      .group("courses.name")
      .sum("score_snapshots.total_score")
  end

  def weekly
    min = Delivery.minimum(:service_date) || Date.current
    max = Delivery.maximum(:service_date) || Date.current
    first = min.beginning_of_week(:monday)
    last  = max.beginning_of_week(:monday)

    @weeks = []
    d = last
    while d >= first
      @weeks << d
      d -= 1.week
    end

    @start_date = (params[:start_date].presence&.to_date || @weeks.first || Date.current.beginning_of_week(:monday))
    @end_date   = @start_date + 6.days
    range = @start_date..@end_date

    courses = Course.order(:id)

    series = courses.map do |course|
      data = Delivery
        .joins(:score_snapshots)
        .where(course_id: course.id, service_date: range)
        .group_by_day(:service_date, range: range)
        .sum("score_snapshots.total_score")

      filled = range.each_with_object({}) { |day, h| h[day] = data[day] || 0 }
      { name: course.name, data: filled }
    end

    # 最大値（背景ボックスの上端用）
    max_value = series.flat_map { |s| s[:data].values }.map(&:to_i).max || 0
    @y_max = (max_value * 1.1).ceil

    # 平均（横一直線にしたいので「全点の平均」）
    days = range.count
    course_count = series.size
    total_all = range.sum do |day|
      series.sum { |s| s[:data][day].to_i }
    end
    @avg_value = course_count.zero? || days.zero? ? 0 : (total_all.to_f / (course_count * days)).round

    avg_line = range.each_with_object({}) { |day, h| h[day] = @avg_value }

    series << {
      name: "平均",
      data: avg_line,
      dataset: {
        borderColor: "#ff1744",
        borderWidth: 3,
        borderDash: [ 8, 6 ],
        pointRadius: 0
      }
    }

    @weekly_scores = series
    @range_start = range.first.to_s
    @range_end   = range.last.to_s
  end

  def monthly
    min = Delivery.minimum(:service_date) || Date.current
    max = Delivery.maximum(:service_date) || Date.current
    first = min.beginning_of_month
    last  = max.beginning_of_month

    @months = []
    m = last
    while m >= first
      @months << m
      m = m.prev_month
    end

    @month = (params[:month].presence&.to_date || @months.first || Date.current.beginning_of_month)
    range = @month.beginning_of_month..@month.end_of_month

    courses = Course.order(:id)

    series = courses.map do |course|
      data = Delivery
        .joins(:score_snapshots)
        .where(course_id: course.id, service_date: range)
        .group_by_day(:service_date, range: range)
        .sum("score_snapshots.total_score")

      filled = range.each_with_object({}) { |day, h| h[day] = data[day] || 0 }
      { name: course.name, data: filled }
    end

    max_value = series.flat_map { |s| s[:data].values }.map(&:to_i).max || 0
    @y_max = (max_value * 1.1).ceil

    days = range.count
    course_count = series.size
    total_all = range.sum do |day|
      series.sum { |s| s[:data][day].to_i }
    end
    @avg_value = course_count.zero? || days.zero? ? 0 : (total_all.to_f / (course_count * days)).round

    avg_line = range.each_with_object({}) { |day, h| h[day] = @avg_value }

    series << {
      name: "平均",
      data: avg_line,
      dataset: {
        borderColor: "#ff1744",
        borderWidth: 3,
        borderDash: [ 8, 6 ],
        pointRadius: 0
      }
    }

    @monthly_scores = series
    @range_start = range.first.to_s
    @range_end   = range.last.to_s
  end
end
