class KeywordCategory

  include Tripod::Resource

  # @prefix keywordcategory: <http://artsapi.com/id/keywords/category/> .

  rdf_type 'http://artsapi.com/def/arts/keywords/Category'
  graph_uri 'http://artsapi.com/def/arts/keywords/keywords'

  field :label, RDF::RDFS.label

end