FactoryGirl.define do
  factory :domain do

    rdf_type 'http://artsapi.com/def/arts/Domain'

    transient do
      uri { RDF::URI('http://artsapi.com/id/domains/widgetcorp-org') }
      graph_uri 'http://artsapi.com/graph/domains'
    end

    label "widgetcorp.org"
    has_url "http://widgetcorp.org"

    initialize_with { new(uri, graph_uri) }

  end
end