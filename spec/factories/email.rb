FactoryGirl.define do
  factory :email do

    rdf_type { RDF::URI('http://artsapi.com/def/arts/Email') }
    graph_uri { RDF::URI('http://artsapi.com/graph/emails') }

    transient do
      sequence(:uri) { |n| "http://artsapi.com/id/emails/email-#{n}" }
    end

    sender { RDF::URI("http://artsapi.com/id/people/jeff-widgetcorp-org") }
    recipient { [RDF::URI("http://artsapi.com/id/people/walter-widgetcorp-org")] }

    # cc_recipient {  }
    # has_domain { RDF::URI("http://artsapi.com/id/domains/widgetcorp-org") }

    contains_keywords {[
      FactoryGirl.create(:keyword),
      FactoryGirl.create(:keyword, 
        uri: RDF::URI('http://artsapi.com/id/keywords/keyword/planning'), 
        label: 'Planning', 
        in_sub_category: RDF::URI('http://artsapi.com/id/keywords/subcategory/operational'))
      ]}

    # sent_at {  }

    initialize_with { new(rdf_type, graph_uri) }

  end
end