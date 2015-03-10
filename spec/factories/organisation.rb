FactoryGirl.define do
  factory :organisation do

    initialize_with { new(uri, graph_uri) }

    rdf_type { RDF::URI('http://www.w3.org/ns/org#Organization') }

    transient do
      uri { RDF::URI('http://artsapi.com/id/organisations/widgetcorp-org') }
      graph_uri { RDF::URI('http://artsapi.com/graph/organisations') }
    end

    label "widgetcorp.org"
    has_members {[]}
    linked_to {[]}
    owns_domain { RDF::URI('http://artsapi.com/id/domains/widgetcorp-org') }

  end
end