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

    # get an oauth access token
    access_token = db_session.get_access_token
    UploadClient.save_current_user_auth_code!(access_token)

    flash[:success] = "You have successfully authorized your Dropbox."

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
      @upload_client = UploadClient.new
      @upload_client.upload!(file_location_string, mine_keywords)

      if flash.has_key? :success
        flash[:success] << ", upload of file '#{file_location_string}' succeeded"
      else
        flash[:success] = "Upload of file '#{file_location_string}' succeeded"
      end

      render nothing: true, status: 200
    rescue

      if flash.has_key? :danger
        flash[:danger] << ", upload of file '#{file_location_string}' failed"
      else
        flash[:danger] = "Upload of file '#{file_location_string}' failed, please try again"
      end

      render nothing: true, status: 500
    end
  end

  # this method should be triggered by the user 
  # once they've uploaded all their data
  # I feel pretty sorry for Fuseki, this will be big
  def process_data

    begin
      job_ids = Organisation.bootstrap_all!

      flash[:success] = "Success! #{job_ids.count} data tasks scheduled."
      render nothing: true, status: 202
    rescue
      flash[:danger] = "There was an error, please try scheduling later."
      render nothing: true, status: 500
    end

  end

end