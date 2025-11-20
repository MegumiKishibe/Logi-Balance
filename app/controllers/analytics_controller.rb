class AnalyticsController < ApplicationController
  def index
    # 単日用
    @date = params[:date] || Date.today
    @deliveries = Delivery.where(service_date: @date)
                          .includes(:course, :score_snapshots)
  end

  def weekly
    # 週次用
    @start_date = params[:start_date] || Date.today.beginning_of_week
    @end_date   = @start_date.to_date + 6.days

    @deliveries = Delivery.where(service_date: @start_date..@end_date)
                          .includes(:course, :score_snapshots)
  end

  def monthly
    # 月次用
    @month = params[:month] || Date.today.beginning_of_month
    @deliveries = Delivery.where(service_date: @month..@month.end_of_month)
                          .includes(:course, :score_snapshots)
  end
end
