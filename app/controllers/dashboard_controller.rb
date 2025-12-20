class DashboardController < ApplicationController
  # コース選択画面
  def courses
    @courses = Course.all
  end

  # ALL（日別集計）
  def index
    @course =
      if params[:id].present?
        Course.find(params[:id])
      else
        Course.first
      end

    @deliveries = @course.deliveries.order(service_date: :desc)
  end

  # 単日実績
  def daily
    @course =
    if params[:id].present?
      Course.find(params[:id])
    else
      Course.first
    end

    @dates = @course.deliveries.order(service_date: :desc).pluck(:service_date) # 利用可能な日付一覧取得

    @date = params[:date] || @dates.first # パラメータの日付、または最新日付を設定

    @delivery = @course.deliveries.find_by(service_date: @date) # 当日の配達実績取得

    if @delivery
      @stops = @delivery.delivery_stops.where.not(completed_at: nil).order(:completed_at)
    else
      @stops = []
    end
  end
end
