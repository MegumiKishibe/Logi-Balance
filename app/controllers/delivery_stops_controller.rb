class DeliveryStopsController < ApplicationController
  def new
    @delivery = Delivery.find(params[:delivery_id])
    @delivery_stop = DeliveryStop.new

    @delivery_stops = @delivery.delivery_stops
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
                                  .where(completed_at: Time.zone.today.all_day)
                                  .order(completed_at: :asc)
  end

  def complete
    @delivery_stop = DeliveryStop.find(params[:id])
    @delivery_stop.update!(completed_at: Time.current)

    delivery = @delivery_stop.delivery

    if delivery.delivery_stops.where(completed_at: nil).none?
      save_score_snapshot(delivery)
    end

    render json: { status: "ok" }, status: :ok
  end

  private

  def save_score_snapshot(delivery)
    # 後でサービスオブジェクトに移す
    ScoreSnapshot.create!(
    delivery_id: delivery.id,
    work_score: 0,
    density_score: 0,
    total_score: 0
  )
  end


  def destroy
    @delivery_stop = DeliveryStop.find(params[:id])

    if @delivery_stop.destroy
      render json: { status: "ok" }, status: :ok
    else
      render json: { error: "削除に失敗しました" }, status: :unprocessable_entity
    end
  end


  private

  def delivery_stop_params
    params.require(:delivery_stop).permit(:delivery_id, :destination_id, :packages_count, :pieces_count)
  end
end
