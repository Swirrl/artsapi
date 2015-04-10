FactoryGirl.define do
  factory :email do

    initialize_with { new(uri, graph_uri) }

    rdf_type { RDF::URI('http://data.artsapi.com/def/arts/Email') }

    transient do 
      sequence(:uri) { |n| RDF::URI("http://data.artsapi.com/id/emails/email-#{n}") }
      graph_uri { RDF::URI('http://data.artsapi.com/graph/emails') }
    end

    sender { RDF::URI("http://data.artsapi.com/id/people/jeff-widgetcorp-org") }
    recipient { [RDF::URI("http://data.artsapi.com/id/people/walter-widgetcorp-org")] }

    contains_keywords {[
      RDF::URI('http://data.artsapi.com/id/keywords/keyword/ask'),
      RDF::URI('http://data.artsapi.com/id/keywords/keyword/planning')
      ]}

  end
end