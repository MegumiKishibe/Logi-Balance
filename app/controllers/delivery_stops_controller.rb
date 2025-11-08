class DeliveryStopsController < ApplicationController
  def new
    @delivery = Delivery.find(params[:delivery_id])
    @delivery_stop = DeliveryStop.new
  end
end
