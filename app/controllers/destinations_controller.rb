class DestinationsController < ApplicationController
  def new
  end

  def create
  end

  def edit
    @destination = Destination.find(params[:id])
  end

  def update
    @destination = Destination.find(params[:id])
    if @destination.update(destination_params)
      redirect_to destination_settings_path, notice: "配達先を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def destination_params
    params.require(:destination).permit(:name, :address)
  end
end
