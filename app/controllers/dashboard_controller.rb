require "csv"

class DashboardController < ApplicationController
  # コース選択画面
  def courses
    @delivery_routes = DeliveryRoute.all
  end

  # 前日（日別集計）
  def index
    @delivery_route =
      if params[:id].present?
        DeliveryRoute.find(params[:id])
      else
        DeliveryRoute.first
      end

    base = @delivery_route.daily_course_runs.completed

    @page_dates = base
      .select(:service_date)
      .distinct
      .order(service_date: :desc)
      .page(params[:page])
      .per(10)

    dates = @page_dates.map(&:service_date)

    @daily_course_runs =
      if dates.any?
        base.where(service_date: dates).order(service_date: :desc, id: :desc)
      else
        base.none
      end

    @daily_course_runs = @daily_course_runs.includes(:daily_course_run_stops, :daily_course_run_score_snapshots)
  end

  # 単日実績（CSV対応）
  def daily
    @delivery_route =
      if params[:id].present?
        DeliveryRoute.find(params[:id])
      else
        DeliveryRoute.first
      end

    @dates = DailyCourseRun.completed.where(delivery_route_id: @delivery_route.id)
      .distinct
      .order(service_date: :desc)
      .pluck(:service_date)

    base = params[:date].presence || @dates.first || Date.current
    @date = base.to_date

    @daily_course_run = DailyCourseRun.completed.find_by(delivery_route_id: @delivery_route.id, service_date: @date)

    @stops =
      if @daily_course_run
        @daily_course_run.daily_course_run_stops
          .includes(:destination)
          .where.not(completed_at: nil)
          .order(:completed_at)
      else
        DailyCourseRunStop.none
      end

    respond_to do |format|
      format.html
      format.csv do
        send_data build_daily_csv(@delivery_route, @date, @daily_course_run, @stops),
                  filename: "daily_#{@delivery_route.id}_#{@date}.csv",
                  type: "text/csv; charset=utf-8"
      end
    end
  end

  private

  def build_daily_csv(delivery_route, date, daily_course_run, stops)
    bom = "\uFEFF" # Excel文字化け対策

    distance_km =
      if daily_course_run&.odo_start_km && daily_course_run&.odo_end_km
        daily_course_run.odo_end_km - daily_course_run.odo_start_km
      end

    minutes =
      if stops.exists? && stops.first.completed_at && stops.last.completed_at
        ((stops.last.completed_at - stops.first.completed_at) / 60).to_i
      end

    total_score = daily_course_run&.daily_course_run_score_snapshots&.last&.total_score

    csv = CSV.generate do |c|
      c << [ "日付", "コース", "配達先", "住所", "件数", "個数", "完了時間" ]

      stops.each do |stop|
        c << [
          date,
          delivery_route.name,
          stop.destination&.name,
          stop.destination&.address,
          stop.packages_count,
          stop.pieces_count,
          stop.completed_at&.in_time_zone("Asia/Tokyo")&.strftime("%H:%M")
        ]
      end

      c << []
      c << [ "合計件数", stops.count ]
      c << [ "合計個数", stops.sum(:pieces_count) ]
      c << [ "走行距離(km)", distance_km ]
      c << [ "所要時間(分)", minutes ]
      c << [ "負担ポイント", total_score ]
    end

    bom + csv
  end
end
