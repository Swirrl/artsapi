class PeopleWorker

  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => 1

  def perform(uri, current_user_id)

    person = Person.find(uri)

    # reload graph vis
    Rails.logger.debug "> [Sidekiq]: Generating graph for #{uri}"
    graph_json = D3::ConnectionsGraph.new(person).formatted_hash
    person.set_visualisation_graph(graph_json)

    # reload email counts
    Rails.logger.debug "> [Sidekiq]: Re-generating email counts for #{uri}"
    person.number_of_incoming_emails(true)
    person.number_of_sent_emails(true)

  end

end