class UploadsController < ApplicationController

  before_filter :authenticate_user!

  # this controller is effectively a wizard-like flow for authing with Dropbox.

  # step 1: we give the user an auth url
  def index
    @upload_client = UploadClient.new
  end

  # step 2: we receive a auth code from the user
  def authorize
    code = params[:code]
    @upload_client.authenticate_with(code)
  end

  # NB: we skip step 1 & 2 if the current_user already has
  # a dropbox_auth_token field populated
  # step 3: create a dropbox client using the auth code
  # then fetch the file from the location passed in params
  def create_client_and_fetch_file
    
  end

end