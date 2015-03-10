FactoryGirl.define do
  factory :keyword do

    initialize_with { new(uri, graph_uri) }

    rdf_type { [RDF::URI('http://artsapi.com/def/arts/keywords/Keyword')] }

    transient do 
      uri { RDF::URI('http://artsapi.com/id/keywords/keyword/ask') }
      graph_uri { RDF::URI('http://artsapi.com/def/arts/keywords/keywords') }
    end

    label 'Ask'
    in_sub_category { RDF::URI('http://artsapi.com/id/keywords/subcategory/research') }

  end
end