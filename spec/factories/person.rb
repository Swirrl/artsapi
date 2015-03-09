FactoryGirl.define do
  factory :person do

    rdf_type { RDF::URI('http://xmlns.com/foaf/0.1/Person') }
    graph_uri { RDF::URI('http://artsapi.com/graph/people') }

    transient do
      email "jeff@widgetcorp.org"
    end

    uri { RDF::URI("http://artsapi.com/id/people/#{email.gsub(/@/, '-').gsub(/\./, '-')}") }

    # account {[]}
    sequence(:name, 'i') { |n| "Jeff Lebowsk#{n}" }

    # given_name nil
    # family_name nil
    # knows {  }

    made {[
      FactoryGirl.create(:email, sender: uri )
      FactoryGirl.create(:email, sender: uri )
    ]}

    has_email { email }
    mbox { email }
    member_of { RDF::URI("http://artsapi.com/id/organisations/#{email.match(/@.+/)[0][1..-1].gsub(/\./, '-')}") }

    connections {[]}

    # position {  }
    # department {  }
    # possible_department {  }

  end
end