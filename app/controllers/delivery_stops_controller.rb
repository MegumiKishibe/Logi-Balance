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
    @delivery =
      current_employee.deliveries.find_by(id: params[:delivery_id]) ||
      current_employee.deliveries.where(service_date: Date.current).order(started_at: :desc).first

    unless @delivery
      @delivery_stops = DeliveryStop.none
      @completed_stops = DeliveryStop.none
      @pending_stops = DeliveryStop.none
      @total_packages = 0
      @total_pieces = 0
      @work_seconds = 0
      @distance_km = nil
      return
    end

    base = @delivery.delivery_stops.includes(:destination)

    # 完了分（完了順に）
    @completed_stops =
      base.where(completed_at: Time.zone.today.all_day)
          .order(completed_at: :asc, id: :asc)

    # 未完了（必要なら表示用）
    @pending_stops =
      base.where(completed_at: nil)
          .order(created_at: :asc, id: :asc)

    # 既存view互換
    @delivery_stops = @completed_stops.includes(delivery: :course)

    # 合計
    @total_packages = @completed_stops.sum(:packages_count)
    @total_pieces   = @completed_stops.sum(:pieces_count)

    # 時間（最後-最初：完了時刻ベース）
    first = @completed_stops.minimum(:completed_at)
    last  = @completed_stops.maximum(:completed_at)
    @work_seconds = (first && last) ? (last - first).to_i : 0

    # 指針（終了-開始）
    if @delivery.odo_start_km.present? && @delivery.odo_end_km.present? && @delivery.odo_end_km.to_i > 0
      @distance_km = @delivery.odo_end_km - @delivery.odo_start_km
    end
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
    scores = ScoreCalculator.new(delivery).calculate

    ScoreSnapshot.create!(
      delivery: delivery,
      work_score: scores[:work],
      density_score: (scores[:density] * 100).round,
      total_score: scores[:total]
    )
  end
end
