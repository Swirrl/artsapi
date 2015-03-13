FactoryGirl.define do
  factory :person do

    initialize_with { new(uri, graph_uri) }

    rdf_type { RDF::URI('http://xmlns.com/foaf/0.1/Person') }

    transient do
      email "jeff@widgetcorp.org"
      uri { RDF::URI("http://artsapi.com/id/people/#{email.gsub(/@/, '-').gsub(/\./, '-')}") }
      graph_uri { RDF::URI('http://artsapi.com/graph/people') }
    end

    sequence(:name, 'i') { |n| "Jeff Lebowsk#{n}" }

    made {[]}

    has_email { email }
    mbox { email }
    member_of { RDF::URI("http://artsapi.com/id/organisations/#{email.match(/@.+/)[0][1..-1].gsub(/\./, '-')}") }

    connections {[]}

  end
end