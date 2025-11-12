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
    employee_id = session[:employee_id] # ログイン中の社員IDを取得
    course_id = params[:delivery][:course_id] # new画面のフォームで選ばれたコースIDを取得
    odo_start_km = params[:delivery][:odo_start_km] # new画面のフォームで入力された出発時の走行距離を取得

    @delivery = Delivery.new(
    employee_id: employee_id,
    course_id: course_id,
    service_date: Date.today,
    started_at: Time.current,
    odo_start_km: odo_start_km,
    odo_end_km: 0)

    if @delivery.save
      redirect_to new_delivery_delivery_stop_path(@delivery),
        notice: "コースを開始しました。"
    else
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
