class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  helper_method :current_employee

  private

  def current_employee
    # ログイン時に session に社員IDを入れている前提
    @current_employee ||= Employee.find_by(id: session[:employee_id])
  end

  allow_browser versions: :modern
end
