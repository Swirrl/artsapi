class ConnectionsWorker

  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => 3

  def perform(uri, current_user_id)

    person = Person.find(uri)

    Rails.logger.debug "> [Sidekiq]: Generating connections for #{uri}"
    person.get_connections!

  end

end