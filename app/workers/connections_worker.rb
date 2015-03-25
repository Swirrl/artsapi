class ConnectionsWorker

  include Sidekiq::Worker

  sidekiq_options :retry => 3

  def perform(uri)
    person = Person.find(uri)
    person.get_connections!
  end

end