class DeliveriesController < ApplicationController
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
