class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_current_user_and_check_jobs

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
    # TODO!
    # something like
    # job_list = User.current_user.active_jobs
    # flash.now[:info] = "There are #{job_list.count} jobs in progress."
  end

  def set_current_user_and_check_jobs
    set_current_user
    check_active_jobs
  end

end
