require 'dropbox_sdk'

class UploadClient

  # NB: :app_key and :app_secret are passed in when you start the docker container
  attr_accessor :app_key, :app_secret, :flow, :access_token, :user_id, :client

  def initialize
    self.app_key = ArtsAPI.dropbox_app_key
    self.app_secret = ArtsAPI.dropbox_app_secret

    if UploadClient.current_user_has_auth_code?
      self.access_token = UploadClient.create_dropbox_session
      create_client
    end
  end

  # Create a Dropbox client
  def create_client
    self.client = DropboxClient.new(self.access_token)
  end

  # Using a file location string, download the file and send to Grafter
  def upload!(file_location_string)
    contents, metadata = self.client.get_file_and_metadata(file_location_string)

    begin
      GrafterAPI.send_to_grafter!(contents)
    rescue Exception => e
      if Rails.env.production?
        Rails.logger.debug "Error: #{e.message}\n\nStack:\n#{e.backtrace}"
      else
        puts "Error: #{e.message}\n\nStack:\n#{e.backtrace}"
      end

      raise GrafterAPI::ImportError
    end
  end

  class << self

    def save_current_user_auth_code!(access_token)
      current_user = User.current_user
      current_user.dropbox_auth_token = access_token.key
      current_user.dropbox_auth_secret = access_token.secret
      current_user.save
    end

    # Check if the signed in user already has an auth code
    def current_user_has_auth_code?
      !!(!User.current_user.dropbox_auth_token.nil?)
    end

    # Create a dropbox session from data stored on the User
    def create_dropbox_session
      db_session = DropboxSession.new(ArtsAPI.dropbox_app_key, ArtsAPI.dropbox_app_secret)

      if self.current_user_has_auth_code?
        key = User.current_user.dropbox_auth_token
        secret = User.current_user.dropbox_auth_secret

        db_session.set_access_token(key, secret)
      end

      db_session
    end

  end
end