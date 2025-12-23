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

    base = @course.deliveries

    # 日付（service_date）を10個ずつページング
    @page_dates = base
      .select(:service_date)
      .distinct
      .order(service_date: :desc)
      .page(params[:page])
      .per(10)

    dates = @page_dates.map(&:service_date)

    # その10日分だけ deliveries を取得
    @deliveries =
      if dates.any?
        base.where(service_date: dates).order(service_date: :desc, id: :desc)
      else
        base.none
      end

    @deliveries = @deliveries.includes(:delivery_stops, :score_snapshots)
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

  def dashboard
    base = Delivery.all

    @page_dates = base
      .select(:service_date)
      .distinct
      .order(service_date: :desc)
      .page(params[:page])
      .per(10)

    dates = @page_dates.map(&:service_date)

    if dates.any?
      to   = dates.first
      from = dates.last

      @deliveries = base
        .where(service_date: from..to)
        .order(service_date: :desc, id: :desc)
    else
      @deliveries = base.none
    end
  end
end
