FactoryGirl.define do
  factory :domain do

    rdf_type 'http://artsapi.com/def/arts/Domain'
    graph_uri 'http://artsapi.com/graph/domains'

    uri { RDF::URI('http://artsapi.com/id/domains/widgetcorp-org') }
    label "widgetcorp.org"
    has_url "http://widgetcorp.org"

    initialize_with { new(rdf_type, graph_uri) }

  end
end