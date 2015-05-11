class UploadsController < ApplicationController

  before_filter :authenticate_user!

  # this controller is effectively a wizard-like flow for authing with Dropbox.

  # step 1: the user will be sent to dropbox to auth
  def index
    @upload_client = UploadClient.new
  end

  # step 2: create session and auth
  def authorize
    db_session = DropboxSession.new(ArtsAPI.dropbox_app_key, ArtsAPI.dropbox_app_secret)
    session[:dropbox_session] = dbsession.serialize

    redirect_to dbsession.get_authorize_url url_for(:action => 'dropbox_callback')
  end

  # step 2: we are redirected here after auth
  def dropbox_callback
    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    access_token = dbsession.get_access_token
    session[:dropbox_session] = dbsession.serialize

    upload_client = UploadClient.new
    upload_client.access_token = access_token
    upload_client.save_current_user_auth_code!

    current_user = User.current_user
    current_user.dropbox_session = session[:dropbox_session]
    current_user.save

    session.delete :dropbox_session
    flash[:success] = "You have successfully authorized your Dropbox."

    redirect_to uploads_path
  end

  # NB: we skip step 1 & 2 if the current_user already has
  # a dropbox_auth_token field populated
  # step 3: create a dropbox client using the auth code
  # then fetch the file from the location passed in params
  def create_client_and_fetch_file
    location = params[:location]

    @upload_client = UploadClient.new
    @upload_client.upload!(file_location_string)
  end

end