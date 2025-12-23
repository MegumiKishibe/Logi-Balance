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
