require 'dropbox_sdk'

class UploadClient

  # NB: :app_key and :app_secret are passed in when you start the docker container
  # the others are generated as part of the dropbox auth flow
  attr_accessor :app_key, :app_secret, :flow, :access_token, :user_id, :client

  def initialize
    self.app_key = ArtsAPI.dropbox_app_key
    self.app_secret = ArtsAPI.dropbox_app_secret
    self.access_token = User.current_user.dropbox_auth_token if current_user_has_auth_code?
    # self.flow = DropboxOAuth2FlowNoRedirect.new(self.app_key, self.app_secret)
  end

  # Check if the signed in user already has an auth code
  def current_user_has_auth_code?
    !!(!User.current_user.dropbox_auth_token.nil?)
  end

  def save_current_user_auth_code!
    current_user = User.current_user
    current_user.dropbox_auth_token = self.access_token
    current_user.save
  end

  # # Give the user a url to auth at
  # def get_auth_url
  #   self.flow.start
  # end

  # # The user returns their auth code
  # def authenticate_with(code)
  #   self.access_token, self.user_id = self.flow.finish(code)
  #   save_current_user_auth_code! if !current_user_has_auth_code?
  # end

  # Create a Dropbox client
  def create_client
    self.client = DropboxClient.new(self.access_token)
  end

  # Using a file location string, download the file and send to Grafter
  def upload!
    contents, metadata = self.client.get_file_and_metadata(file_location_string)

    begin
      GrafterAPI.send_to_grafter!(contents)
    rescue
      raise ThatDidntWorkError
    end
  end
end