class AnalyticsController < ApplicationController
  def index
    @dates = Delivery.distinct.order(service_date: :desc).pluck(:service_date)

    @date = (params[:date] || @dates.first).to_date

    @daily_scores = Delivery
      .joins(:score_snapshots, :course)
      .where(service_date: @date)
      .group("courses.name")
      .sum("score_snapshots.total_score")
  end

  def weekly
    @weeks = (0..12).map { |i| Date.today.beginning_of_week(:monday) - i.weeks }
    @start_date = (params[:start_date] || Date.today.beginning_of_week(:monday)).to_date
    @end_date   = @start_date + 6.days

    @week_label = "#{@start_date.strftime("%m/%d")}〜#{@end_date.strftime("%m/%d")}" # 表示用ラベル

    @deliveries = Delivery.where(service_date: @start_date..@end_date) # 配達実績取得

    @weekly_scores = Delivery
      .joins(:score_snapshots)
      .where(service_date: @start_date..@end_date)
      .group_by_day(:service_date)
      .sum("score_snapshots.total_score")
  end

  def monthly
    @months = (0..11).map { |i| Date.today.beginning_of_month << i }
    @month = (params[:month] || Date.today.beginning_of_month).to_date

    @start_date = @month
    @end_date   = @month.end_of_month

    @deliveries = Delivery.where(service_date: @month..@month.end_of_month)

    @monthly_scores = Delivery
      .joins(:score_snapshots)
      .where(service_date: @month..@month.end_of_month)
      .group_by_day(:service_date)
      .sum("score_snapshots.total_score")
  end
end
