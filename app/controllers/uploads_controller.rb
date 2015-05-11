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

    @upload_client = UploadClient.new
    @upload_client.upload!(file_location_string)
  end

end