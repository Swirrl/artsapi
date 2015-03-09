FactoryGirl.define do
  factory :keyword do

    rdf_type { [RDF::URI('http://artsapi.com/def/arts/keywords/Keyword')] }
    graph_uri { RDF::URI('http://artsapi.com/def/arts/keywords/keywords') }

    uri { RDF::URI('http://artsapi.com/id/keywords/keyword/ask') }
    label 'Ask'
    in_sub_category { RDF::URI('http://artsapi.com/id/keywords/subcategory/research') }

  end
end