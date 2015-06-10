require 'dropbox_sdk'

class UploadsController < ApplicationController

  before_filter :authenticate_user!

  # this controller is effectively a wizard-like flow for authing with Dropbox.

  # step 1: the user will be sent to dropbox to auth
  def index
  end

  # step 2: create session and auth
  def authorize
    db_session = UploadClient.create_dropbox_session
    session[:dropbox_session] = db_session.serialize

    redirect_to db_session.get_authorize_url url_for(:action => 'dropbox_callback')
  end

  # step 2: we are redirected here after auth
  def dropbox_callback
    db_session = DropboxSession.deserialize(session[:dropbox_session])

    unless params[:not_approved] == 'true'
      # get an oauth access token
      access_token = db_session.get_access_token
      UploadClient.save_current_user_auth_code!(access_token)

      flash[:success] = "You have successfully authorized your Dropbox."
    else
      flash[:danger] = "You have to authorize to continue."
    end

    redirect_to uploads_path
  end

  # NB: we skip step 1 & 2 if the current_user already has
  # a dropbox_auth_token field populated
  # step 3: create a dropbox client using the auth code
  # then fetch the file from the location passed in params
  def create_client_and_fetch_file
    file_location_string = params[:location].chomp
    mine_keywords = !!(params[:mine_keywords])

    begin

      upload_file_async(file_location_string, mine_keywords)

      flash[:success] = "Upload of file '#{file_location_string}' queued."

      render nothing: true, status: 200
    rescue Exception => e

      Rails.logger.debug "Error: #{e.class.to_s} #{e.message}\n\nStack:\n"
      e.backtrace.map { |line| Rails.logger.debug(line) }

      flash[:danger] = "Upload of file '#{file_location_string}' failed, please try again"

      render nothing: true, status: 500
    end
  end

  # this method should be triggered by the user 
  # once they've uploaded all their data
  # I feel pretty sorry for Fuseki, this will be big
  def process_data
    # do we want to force generation of everything?
    force_all = params[:force] if params.has_key?(:force)

    begin
      job_ids = force_all ? Organisation.bootstrap_all! : Organisation.bootstrap_owner_or_largest_org!

      flash[:success] = "Success! #{job_ids.count} data tasks scheduled."
      render nothing: true, status: 202
    rescue
      flash[:danger] = "There was an error, please try scheduling later."
      render nothing: true, status: 500
    end

  end

  private

  def upload_file_async(file_location_string, mine_keywords)
    current_user_id = User.current_user.id.to_s
    job_id = ::UploadsWorker.perform_in(10.seconds, 'true', current_user_id, file_location_string, mine_keywords)

    User.add_job_for_current_user(job_id)

    job_id
  end

end