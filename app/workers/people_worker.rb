class PeopleWorker

  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => 1, :dead => false

  def perform(uri, current_user_id)

    person = Person.find(uri)

    # reload graph vis
    logger.debug "> [Sidekiq]: Generating graph for #{uri}"
    graph_json = D3::ConnectionsGraph.new(person).formatted_hash
    person.set_visualisation_graph(graph_json)

    # reload email counts
    logger.debug "> [Sidekiq]: Re-generating email counts for #{uri}"
    person.number_of_incoming_emails(true)
    person.number_of_sent_emails(true)
    SNA.degree_centrality_for_person!(uri, true)

  end

end