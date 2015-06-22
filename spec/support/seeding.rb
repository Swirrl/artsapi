def bootstrap_sic!
  path_to_sic = Rails.root.to_s + "/lib/sic2007.ttl"
  sic_graph = 'http://data.artsapi.com/graph/sic'

  Rails.logger.debug "> [SICBootstrap] File path: #{path_to_sic}"
  Rails.logger.debug "> [SICBootstrap] Uploading..."

  user.set_tripod_endpoints!

  User.post_to_data_endpoint(sic_graph, path_to_sic)
end

def bootstrap_keywords!
  path_to_keywords = Rails.root.to_s + "/lib/keywords_resources.ttl"
  keywords_graph = 'http://data.artsapi.com/graph/keywords'

  Rails.logger.debug "> [KeywordsBootstrap] File path: #{path_to_keywords}"
  Rails.logger.debug "> [KeywordsBootstrap] Uploading..."

  user.set_tripod_endpoints!

  User.post_to_data_endpoint(keywords_graph, path_to_keywords)
end

def seed_keyword_mentions_for(organisation)
  organisation.has_members.each do |uri|
    p = Person.find(uri)
    mock_pipeline_for_keywords_for(p)
  end
end

def mock_pipeline_for_keywords_for(person)
  uris = person.all_emails.map { |e| e.contains_keywords }.flatten
  person.mentioned_keywords = uris
  person.save
end