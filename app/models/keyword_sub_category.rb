class KeywordSubCategory

  include Tripod::Resource

  # @prefix keywordsubcategory: <http://data.artsapi.com/id/keywords/subcategory/> .

  rdf_type 'http://data.artsapi.com/def/arts/keywords/KeywordSubCategory'
  graph_uri 'http://data.artsapi.com/def/arts/keywords/keywords'

  field :label, RDF::RDFS.label
  field :in_category, 'http://data.artsapi.com/def/arts/keywords/inCategory', is_uri: true

end