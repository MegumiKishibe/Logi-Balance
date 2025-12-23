class SettingsController < ApplicationController
  # 設定トップ画面
  def index
  end

  # Driver 設定画面
  def driver
    @employees = Employee.order(:last_name_en, :first_name_en)

    if params[:employee_id].present?
      @selected_employee = Employee.find(params[:employee_id])
    else
      @selected_employee = Employee.new(id: 0) # フォームを空状態にする
    end
  end

  # 配達先
  def destination
    @destinations = Destination.all.order(:name)

    if params[:destination_id].present?
      @selected_destination = Destination.find(params[:destination_id])
    else
      @selected_destination = Destination.new(id: 0)
    end
  end

  def update_destination
    destination = Destination.find(params[:destination][:id])

    if destination.update(destination_params)
      redirect_to destination_settings_path, notice: "配達先を更新しました。"
    else
      redirect_to destination_settings_path, alert: "更新に失敗しました。"
    end
  end

  # Confirm ボタン → 更新
  # ※ここが private の下にあると ActionNotFound(404) になるので、private より上に置く
  def update_driver
    employee = Employee.find(params[:employee][:id]) # ★ id を使って取得する

    if employee.update(employee_params)
      redirect_to driver_settings_path, notice: "ドライバー情報を更新しました。"
    else
      redirect_to driver_settings_path, alert: "更新に失敗しました。"
    end
  end

  private

  def destination_params
    params.require(:destination).permit(:name, :address, :id)
  end

  def employee_params
    params.require(:employee).permit(
      :employee_no,
      :last_name_ja,
      :first_name_ja,
      :last_name_en,
      :first_name_en,
      :hired_on,
      :id  # ★これを permit しないと取得できない
    )
  end
end
