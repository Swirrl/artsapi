class UploadsWorker

  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => 3, :dead => false

  def perform(_, current_user_id, file_location_string, mine_keywords)

    upload_client = UploadClient.new

    logger.debug "> [Sidekiq]: uploading #{file_location_string}, triggered by #{User.current_user.email}"

    upload_client.upload!(file_location_string, mine_keywords)

  end

end