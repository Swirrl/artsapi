class UploadsWorker

  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => 3

  def perform(current_user_id, file_location_string, mine_keywords)

    # set the current_user so we can look up the person
    User.current_user = User.find(current_user_id)

    upload_client = UploadClient.new

    Rails.logger.debug "> Sidekiq: uploading #{file_location_string}, triggered by #{User.current_user.email}"

    upload_client.upload!(file_location_string, mine_keywords)
  end

end