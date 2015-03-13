class ConnectionsWorker

  include Sidekiq::Worker

  # designed to call Person.get_connections!
  # or Organisation.generate_all_connections!
  def perform(object, connection_writing_method)
    object.send(:connection_writing_method)
  end

end