class DeliveriesController < ApplicationController
  before_action :authenticate_employee!

  def index
    @deliveries = Delivery.includes(:employee, :course).order(service_date: :desc)
  end

  def new
    @delivery = Delivery.new
    @employees = Employee.all
    @courses = Course.all
  end

  def create
    @delivery = current_employee.deliveries.new(
      course_id: params[:delivery][:course_id],
      service_date: Date.today,
      started_at: Time.current,
      odo_start_km: params[:delivery][:odo_start_km],
      odo_end_km: 0
    )

    if @delivery.save
      redirect_to new_delivery_delivery_stop_path(@delivery), notice: "コースを開始しました。"
    else
      Rails.logger.error("Delivery save failed: #{@delivery.errors.full_messages.inspect}")
      @courses = Course.all
      render :new, status: :unprocessable_entity
    end
  end


  def show
    @delivery = Delivery.find(params[:id])
  end

  def import
    # 画面表示だけ
  end

  def import_create
    if params[:file].blank?
      redirect_to import_deliveries_path, alert: "CSVファイルを選択してください"
      return
    end

    Rails.logger.info("[CSV] file=#{params[:file]&.original_filename} size=#{params[:file]&.size} type=#{params[:file]&.content_type}")

    result = ::DailyCsvImporter.new(params[:file]).call
    Rails.logger.info("[CSV] result=#{result.inspect}")

    ok = result.is_a?(Hash) ? (result[:ok] || result["ok"]) : result.present?

    unless ok
      error = result.is_a?(Hash) ? (result[:error] || result["error"]) : "取り込みに失敗しました"
      redirect_to import_deliveries_path, alert: error
      return
    end

    imported    = result.is_a?(Hash) ? (result[:imported] || result["imported"]) : nil
    course_name = result.is_a?(Hash) ? (result[:course_name] || result["course_name"]) : nil
    date        = result.is_a?(Hash) ? (result[:date] || result["date"]) : nil

    msg = "取り込み完了"
    msg += "：#{imported}件" if imported
    msg += "（#{course_name} / #{date}）" if course_name && date

    # ---- 負荷ポイント計算 ----
    begin
      course = Course.find_by(name: course_name)
      target_date = date.respond_to?(:to_date) ? date.to_date : Date.parse(date.to_s)
      delivery = Delivery.find_by(course_id: course&.id, service_date: target_date)

      if delivery
        ScoreSnapshotCreator.new(delivery).call
      else
        Rails.logger.warn("[SCORE] delivery not found for course=#{course_name.inspect} date=#{date.inspect}")
      end
    rescue => e
      Rails.logger.error("[SCORE] #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
    end
    # ----------------------------------------------------------

    redirect_to import_deliveries_path, notice: msg
  rescue => e
    Rails.logger.error("[CSV] #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
    redirect_to import_deliveries_path, alert: "取り込み中にエラー：#{e.class} #{e.message}"
  end

  def finish
    @delivery = current_employee.deliveries.find(params[:id])

    odo_end_km = params.dig(:delivery, :odo_end_km)
    if odo_end_km.blank?
      redirect_to new_delivery_delivery_stop_path(@delivery), alert: "終了指針を入力してください"
      return
    end

    if @delivery.update(odo_end_km: odo_end_km, finished_at: Time.current)
      redirect_to delivery_stops_path(delivery_id: @delivery.id), notice: "終了指針を登録しました"
    else
      redirect_to new_delivery_delivery_stop_path(@delivery), alert: "終了指針の登録に失敗しました"
    end
  end

  private

  def delivery_params
    params.require(:delivery).permit(
      :employee_id,
      :course_id,
      :service_date,
      :started_at,
      :finished_at,
      :odo_start_km,
      :odo_end_km
    )
  end
end
