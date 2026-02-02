class AnalyticsController < ApplicationController
  def index
    @dates = DailyCourseRun.distinct.order(service_date: :desc).pluck(:service_date)

    base = params[:date].presence || @dates.first || Date.current
    @date = base.to_date

    @daily_scores = DailyCourseRun
      .joins(:daily_course_run_score_snapshots, :delivery_route)
      .where(service_date: @date)
      .group("delivery_routes.name")
      .sum("daily_course_run_score_snapshots.total_score")

    values = @daily_scores.values.map(&:to_f)
    @avg_value = values.any? ? (values.sum / values.size).round : 0

    max_value = values.max || 0
    @y_max = (max_value * 1.1).ceil
  end

  def weekly
    min = DailyCourseRun.minimum(:service_date) || Date.current
    max = DailyCourseRun.maximum(:service_date) || Date.current
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

    routes = DeliveryRoute.order(:id)

    series = routes.map do |route|
      data = DailyCourseRun
        .joins(:daily_course_run_score_snapshots)
        .where(delivery_route_id: route.id, service_date: range)
        .group_by_day(:service_date, range: range)
        .sum("daily_course_run_score_snapshots.total_score")

      filled = range.each_with_object({}) { |day, h| h[day] = data[day] || 0 }
      { name: route.name, data: filled }
    end

    max_value = series.flat_map { |s| s[:data].values }.map(&:to_i).max || 0
    @y_max = (max_value * 1.1).ceil

    days = range.count
    route_count = series.size
    total_all = range.sum do |day|
      series.sum { |s| s[:data][day].to_i }
    end
    @avg_value = route_count.zero? || days.zero? ? 0 : (total_all.to_f / (route_count * days)).round

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
    min = DailyCourseRun.minimum(:service_date) || Date.current
    max = DailyCourseRun.maximum(:service_date) || Date.current
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

    routes = DeliveryRoute.order(:id)

    series = routes.map do |route|
      data = DailyCourseRun
        .joins(:daily_course_run_score_snapshots)
        .where(delivery_route_id: route.id, service_date: range)
        .group_by_day(:service_date, range: range)
        .sum("daily_course_run_score_snapshots.total_score")

      filled = range.each_with_object({}) { |day, h| h[day] = data[day] || 0 }
      { name: route.name, data: filled }
    end

    max_value = series.flat_map { |s| s[:data].values }.map(&:to_i).max || 0
    @y_max = (max_value * 1.1).ceil

    days = range.count
    route_count = series.size
    total_all = range.sum do |day|
      series.sum { |s| s[:data][day].to_i }
    end
    @avg_value = route_count.zero? || days.zero? ? 0 : (total_all.to_f / (route_count * days)).round

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
