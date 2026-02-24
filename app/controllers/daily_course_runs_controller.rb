class DailyCourseRunsController < ApplicationController
  before_action :authenticate_employee! #認可は不要

  def index
    @daily_course_runs =
      DailyCourseRun.includes(:employee, :delivery_route)
                    .order(service_date: :desc)
  end

  def new
    @daily_course_run = DailyCourseRun.new
    @employees = Employee.all
    @delivery_routes = DeliveryRoute.all
  end

  def create #業務開始
    @daily_course_run = DailyCourseRun.new(
      employee: current_employee, # ログイン中の従業員を設定
      delivery_route_id: params[:daily_course_run][:delivery_route_id],
      service_date: Date.current,
      started_at: Time.current,
      odo_start_km: params[:daily_course_run][:odo_start_km],
      odo_end_km: nil
    )

    if @daily_course_run.save
      redirect_to new_daily_course_run_daily_course_run_stop_path(@daily_course_run),
                  notice: "コースを開始しました。"
    else
      Rails.logger.error("DailyCourseRun save failed: #{@daily_course_run.errors.full_messages.inspect}")
      @delivery_routes = DeliveryRoute.all
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @daily_course_run = DailyCourseRun.find(params[:id])
  end

  def import
    # 画面表示だけ
  end

  def import_create
    if params[:file].blank?
      redirect_to import_daily_course_runs_path, alert: "CSVファイルを選択してください"
      return
    end

    Rails.logger.info("[CSV] file=#{params[:file]&.original_filename} ")

    result = ::DailyCsvImporter.new(params[:file]).call

    if result[:success]
      redirect_to import_daily_course_runs_path, notice: result[:message]
    else
      redirect_to import_daily_course_runs_path, alert: result[:message]
    end

  rescue => e
    Rails.logger.error("[CSV] #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
    redirect_to import_daily_course_runs_path, alert: "取り込み中にエラーが発生しました"
  end

  def finish
    @daily_course_run = DailyCourseRun.find(params[:id])

    odo_end_km = params.dig(:daily_course_run, :odo_end_km)
    if odo_end_km.blank?
      redirect_to new_daily_course_run_daily_course_run_stop_path(@daily_course_run), alert: "終了指針を入力してください"
      return
    end

    if @daily_course_run.update(odo_end_km: odo_end_km, finished_at: Time.current)
      redirect_to daily_course_run_stops_path(daily_course_run_id: @daily_course_run.id),
                  notice: "終了指針を登録しました"
    else
      redirect_to new_daily_course_run_daily_course_run_stop_path(@daily_course_run),
                  alert: "終了指針の登録に失敗しました"
    end
  end

  private

  def daily_course_run_params
    params.require(:daily_course_run).permit(
      :employee_id,
      :delivery_route_id,
      :service_date,
      :started_at,
      :finished_at,
      :odo_start_km,
      :odo_end_km
    )
  end
end
