class DashboardController < ApplicationController
  # コース選択画面
  def courses
    @courses = Course.all
  end

  # ALL（日別集計）
  def index
    @course = Course.find(params[:id])
    @deliveries = @course.deliveries.order(service_date: :desc)
  end

  # 単日実績
  def daily
    @course = Course.find(params[:id])
    @date = params[:date]

    @delivery = @course.deliveries.find_by(service_date: @date)

    if @delivery
      @stops = @delivery.delivery_stops.order(:completed_at)
    else
      @stops = []
    end
  end
end
