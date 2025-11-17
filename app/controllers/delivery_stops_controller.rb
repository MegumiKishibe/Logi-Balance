class DeliveryStopsController < ApplicationController
  protect_from_forgery with: :null_session  # ← API用途では一時的に追加OK

  def new
    @delivery = Delivery.find(params[:delivery_id])
    @delivery_stop = DeliveryStop.new

    @delivery_stops = @delivery.delivery_stops
      .includes(:destination)
      .where(completed_at: nil)
      .where("DATE(created_at) = ?", Date.today)  # ← 追加
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

    respond_to do |format|
      format.json { render json: { status: "ok" }, status: :ok }
      format.html { render body: nil, status: :ok }  # TurboにHTMLなしを明示
    end
  end

  def destroy
    @delivery_stop = DeliveryStop.find(params[:id])
    if @delivery_stop.destroy
      head :ok
    else
      render json: { error: "削除に失敗しました" }, status: :unprocessable_entity
    end
  end


  private

  def delivery_stop_params
    params.require(:delivery_stop).permit(:delivery_id, :destination_id, :packages_count, :pieces_count)
  end
end
