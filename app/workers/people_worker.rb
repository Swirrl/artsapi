class PeopleWorker

  include Sidekiq::Worker

  sidekiq_options :retry => 3

  def perform(uri, current_user_id)

    # set the current_user so we can look up the person
    User.current_user = User.find(current_user_id)
    person = Person.find(uri)

    logger.debug "> Sidekiq: Generating graph for #{uri}"
    graph_json = D3::ConnectionsGraph.new(person).formatted_hash
    person.set_visualisation_graph(graph_json)
  end

end