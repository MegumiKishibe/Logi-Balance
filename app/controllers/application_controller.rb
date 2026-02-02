class ApplicationController < ActionController::Base
  # 全社員にログインを義務付ける
  before_action :authenticate_employee!, unless: :devise_controller?

  # ログイン後の遷移先
  def after_sign_in_path_for(resource)
    new_daily_course_run_path
  end

  # ログアウト後の遷移先
  def after_sign_out_path_for(resource_or_scope)
    new_employee_session_path
  end

  allow_browser versions: :modern
end
