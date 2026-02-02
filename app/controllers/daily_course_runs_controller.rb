class DailyCourseRunsController < ApplicationController
  before_action :authenticate_employee!

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

  def create
    @daily_course_run = DailyCourseRun.new(
      employee: current_employee,
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

    Rails.logger.info("[CSV] file=#{params[:file]&.original_filename} size=#{params[:file]&.size} type=#{params[:file]&.content_type}")

    result = ::DailyCsvImporter.new(params[:file]).call
    Rails.logger.info("[CSV] result=#{result.inspect}")

    ok = result.is_a?(Hash) ? (result[:ok] || result["ok"]) : result.present?
    unless ok
      error = result.is_a?(Hash) ? (result[:error] || result["error"]) : "取り込みに失敗しました"
      redirect_to import_daily_course_runs_path, alert: error
      return
    end

    imported       = result.is_a?(Hash) ? (result[:imported] || result["imported"]) : nil
    route_name     = result.is_a?(Hash) ? (result[:course_name] || result["course_name"]) : nil # importer側のキー互換
    date           = result.is_a?(Hash) ? (result[:date] || result["date"]) : nil

    msg = "取り込み完了"
    msg += "：#{imported}件" if imported
    msg += "（#{route_name} / #{date}）" if route_name && date

    # ---- 負荷ポイント計算 ----
    begin
      delivery_route = DeliveryRoute.find_by(name: route_name)
      target_date = date.respond_to?(:to_date) ? date.to_date : Date.parse(date.to_s)

      daily_course_run =
        DailyCourseRun.find_by(delivery_route_id: delivery_route&.id, service_date: target_date)

      if daily_course_run
        # 既存クラス名を後で改名するならここも合わせる
        ScoreSnapshotCreator.new(daily_course_run).call
      else
        Rails.logger.warn("[SCORE] daily_course_run not found for route=#{route_name.inspect} date=#{date.inspect}")
      end
    rescue => e
      Rails.logger.error("[SCORE] #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
    end
    # ----------------------------------------------------------

    redirect_to import_daily_course_runs_path, notice: msg
  rescue => e
    Rails.logger.error("[CSV] #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
    redirect_to import_daily_course_runs_path, alert: "取り込み中にエラー：#{e.class} #{e.message}"
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
