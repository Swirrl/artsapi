class OrganisationsWorker

  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => 1

  def perform(uri, current_user_id)

    # set the current_user so we can look up the person
    # User.current_user = User.find(current_user_id)
    organisation = Organisation.find(uri)

    Rails.logger.debug "> [Sidekiq]: Generating graph for #{uri}"
    graph_json = D3::OrganisationsGraph.new(organisation).formatted_hash
    organisation.set_visualisation_graph(graph_json)
  end

end