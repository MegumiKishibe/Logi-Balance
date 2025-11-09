class DeliveryStopsController < ApplicationController
  protect_from_forgery with: :null_session  # ← API用途では一時的に追加OK

  def new
    @delivery = Delivery.find(params[:delivery_id])  # ネストで渡される delivery_id を使う
    @delivery_stop = DeliveryStop.new
    @delivery_stops = @delivery.delivery_stops # 紐づくDeliveryのStopのみ
                                .includes(:destination)
                                .where(completed_at: nil)
                                .order(:id)
  end
  def create
    @delivery_stop = DeliveryStop.new(delivery_stop_params)
    if @delivery_stop.save
      render json: { id: @delivery_stop.id }, status: :created
    else
      Rails.logger.error(@delivery_stop.errors.full_messages)
      render json: { error: @delivery_stop.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    @delivery_stops = DeliveryStop.includes(:destination, :delivery)
                                  .where.not(completed_at: nil)
                                  .order(completed_at: :asc)
  end

  def complete
    @delivery_stop = DeliveryStop.find(params[:id])
    if @delivery_stop.update(completed_at: Time.current)
      head :ok
    else
      render json: { error: "更新に失敗しました" }, status: :unprocessable_entity
    end
  end

  private

  def delivery_stop_params
    params.require(:delivery_stop).permit(:delivery_id, :destination_id, :packages_count, :pieces_count)
  end
end
