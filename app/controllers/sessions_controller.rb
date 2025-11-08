class SessionsController < ApplicationController
  def new
  end

  def create
    employee = Employee.find_by(employee_no: params[:employee_no])
    if employee
      session[:employee_id] = employee.id
      redirect_to new_delivery_path, notice: "ログインしました。"
    else
      flash.now[:alert] = "社員番号が正しくありません。"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:employee_id)
    redirect_to login_path, notice: "ログアウトしました。"
  end
end
