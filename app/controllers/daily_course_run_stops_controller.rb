class DailyCourseRunStopsController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_daily_course_run, only: %i[new create]
  before_action :set_daily_course_run_stop, only: %i[complete destroy]

  def new
    @daily_course_run_stop = DailyCourseRunStop.new
    @daily_course_run_stops =
      @daily_course_run.daily_course_run_stops
                      .includes(:destination)
                      .where(completed_at: nil)
                      .order(:id)
  end

  def create
    @daily_course_run_stop =
      @daily_course_run.daily_course_run_stops.new(daily_course_run_stop_params)

    if @daily_course_run_stop.save
      render json: { id: @daily_course_run_stop.id }, status: :created
    else
      Rails.logger.error(@daily_course_run_stop.errors.full_messages.inspect)
      render json: { error: @daily_course_run_stop.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    @daily_course_run =
      current_employee.daily_course_runs.find_by(id: params[:daily_course_run_id]) ||
      current_employee.daily_course_runs.where(service_date: Date.current).order(started_at: :desc).first

    unless @daily_course_run
      @daily_course_run_stops = DailyCourseRunStop.none
      @completed_stops = DailyCourseRunStop.none
      @pending_stops = DailyCourseRunStop.none
      @total_packages = 0
      @total_pieces = 0
      @work_seconds = 0
      @distance_km = nil
      return
    end

    base = @daily_course_run.daily_course_run_stops.includes(:destination)

    @completed_stops =
      base.where(completed_at: Time.zone.today.all_day)
          .order(completed_at: :asc, id: :asc)

    @pending_stops =
      base.where(completed_at: nil)
          .order(created_at: :asc, id: :asc)

    # viewで @daily_course_run_stops を使うなら、未完了一覧にする
    @daily_course_run_stops = @pending_stops

    @total_packages = @completed_stops.sum(:packages_count)
    @total_pieces   = @completed_stops.sum(:pieces_count)

    first = @completed_stops.minimum(:completed_at)
    last  = @completed_stops.maximum(:completed_at)
    @work_seconds = (first && last) ? (last - first).to_i : 0

    if @daily_course_run.odo_start_km.present? && @daily_course_run.odo_end_km.present? && @daily_course_run.odo_end_km.to_i > 0
      @distance_km = @daily_course_run.odo_end_km - @daily_course_run.odo_start_km
    end
  end

  def complete
    @daily_course_run_stop.update!(completed_at: Time.current)

    daily_course_run = @daily_course_run_stop.daily_course_run

    if daily_course_run.daily_course_run_stops.where(completed_at: nil).none?
      save_score_snapshot(daily_course_run)
    end

    render json: { status: "ok", completed_at: @daily_course_run_stop.completed_at }, status: :ok
  rescue => e
    Rails.logger.error("[COMPLETE] #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
    render json: { error: "完了処理でエラーが発生しました" }, status: :internal_server_error
  end

  def destroy
    if @daily_course_run_stop.destroy
      render json: { status: "ok" }, status: :ok
    else
      render json: { error: "削除に失敗しました" }, status: :unprocessable_entity
    end
  end

  private

  def set_daily_course_run
    @daily_course_run = current_employee.daily_course_runs.find(params[:daily_course_run_id])
  end

  def set_daily_course_run_stop
    @daily_course_run_stop = DailyCourseRunStop.find(params[:id])
  end

  def daily_course_run_stop_params
    params.require(:daily_course_run_stop).permit(:destination_id, :packages_count, :pieces_count)
  end

  def save_score_snapshot(daily_course_run)
    scores = ScoreCalculator.new(daily_course_run).calculate

    DailyCourseRunScoreSnapshot.create!(
      daily_course_run: daily_course_run,
      work_score: scores[:work],
      density_score: (scores[:density] * 100).round,
      total_score: scores[:total]
    )
  end
end
