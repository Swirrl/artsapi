class OrganisationsWorker

  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options :retry => 1

  def perform(uri, current_user_id)

    organisation = Organisation.find(uri)

    Rails.logger.debug "> [Sidekiq]: Generating graph for #{uri}"
    graph_json = D3::OrganisationsGraph.new(organisation).formatted_hash
    organisation.set_visualisation_graph(graph_json)

    # reload email counts for users
    Rails.logger.debug "> [Sidekiq]: Re-generating email counts for members of #{uri}"
    organisation.force_regenerate_email_counts!

  end

end