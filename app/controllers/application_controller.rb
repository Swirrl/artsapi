class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_current_user_and_check_jobs
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # Devise fallbacks
  def after_sign_in_path_for(resource)
    "/home"
  end

  def after_sign_out_path_for(resource)
    "/users/sign_in"
  end

  def set_current_user
    User.current_user = current_user
  end

  def check_active_jobs
    job_count = current_user.active_jobs.count
    upload_count = current_user.uploads_in_progress
    total_count = job_count + upload_count
    flash.now[:info] = "There are #{total_count} jobs in progress." if total_count > 0
  end

  def set_current_user_and_check_jobs
    set_current_user
    check_active_jobs if current_user
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| 
      u.permit(:password, :password_confirmation, :current_password) 
    }
  end

end
