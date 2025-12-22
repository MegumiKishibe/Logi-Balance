class DeliveryStopsController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_delivery, only: %i[new create]
  before_action :set_delivery_stop, only: %i[complete destroy]

  def new
    @delivery_stop = DeliveryStop.new
    @delivery_stops = @delivery.delivery_stops
                              .includes(:destination)
                              .where(completed_at: nil)
                              .order(:id)
  end

  def create
    # delivery_id はURL(/deliveries/:delivery_id/...)から確定できるので merge/関連で入れる
    @delivery_stop = @delivery.delivery_stops.new(delivery_stop_params)

    if @delivery_stop.save
      render json: { id: @delivery_stop.id }, status: :created
    else
      Rails.logger.error(@delivery_stop.errors.full_messages.inspect)
      render json: { error: @delivery_stop.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    @delivery_stops = DeliveryStop.includes(:destination, :delivery)
                                  .where(completed_at: Time.zone.today.all_day)
                                  .order(completed_at: :asc)
  end

  def complete
    @delivery_stop = DeliveryStop.find(params[:id])
    @delivery_stop.update!(completed_at: Time.current)

    delivery = @delivery_stop.delivery
    save_score_snapshot(delivery) if delivery.delivery_stops.where(completed_at: nil).none?

    render json: { status: "ok", completed_at: @delivery_stop.completed_at }, status: :ok
  end

  def destroy
    if @delivery_stop.destroy
      render json: { status: "ok" }, status: :ok
    else
      render json: { error: "削除に失敗しました" }, status: :unprocessable_entity
    end
  end

  private

  def set_delivery
    @delivery = Delivery.find(params[:delivery_id])
  end

  def set_delivery_stop
    @delivery_stop = DeliveryStop.find(params[:id])
  end

  # delivery_id はURLで決まるので permit しない
  def delivery_stop_params
    params.require(:delivery_stop).permit(:destination_id, :packages_count, :pieces_count)
  end

  def save_score_snapshot(delivery)
    ScoreSnapshot.create!(
      delivery_id: delivery.id,
      work_score: 0,
      density_score: 0,
      total_score: 0
    )
  end
end
