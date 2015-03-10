FactoryGirl.define do
  factory :organisation do

    rdf_type { RDF::URI('http://www.w3.org/ns/org#Organization') }
    graph_uri { RDF::URI('http://artsapi.com/graph/organisations') }

    transient do
      uri { RDF::URI('http://artsapi.com/id/organisations/widgetcorp-org') }
    end

    label "widgetcorp.org"
    has_members {[]}
    linked_to {[]}
    owns_domain { RDF::URI('http://artsapi.com/id/domains/widgetcorp-org') }
    # works_on {  }

    initialize_with { new(rdf_type, graph_uri) }

  end
end