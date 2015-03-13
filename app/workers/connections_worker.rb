class ConnectionsWorker

  include Sidekiq::Worker

  def perform(uri)
    person = Person.find(uri)
    person.get_connections!
  end

end