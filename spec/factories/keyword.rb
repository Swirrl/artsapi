FactoryGirl.define do
  factory :keyword do

    rdf_type { [RDF::URI('http://artsapi.com/def/arts/keywords/Keyword')] }
    graph_uri { RDF::URI('http://artsapi.com/def/arts/keywords/keywords') }

    transient do
      uri { RDF::URI('http://artsapi.com/id/keywords/keyword/ask') }
    end

    label 'Ask'
    in_sub_category { RDF::URI('http://artsapi.com/id/keywords/subcategory/research') }

    initialize_with { new(rdf_type, graph_uri) }

  end
end