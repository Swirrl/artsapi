class KeywordCategory

  include Tripod::Resource
  extend TripodOverrides

  # @prefix keywordcategory: <http://data.artsapi.com/id/keywords/category/> .

  rdf_type 'http://data.artsapi.com/def/arts/keywords/Category'
  graph_uri 'http://data.artsapi.com/graph/keywords'

  field :label, RDF::RDFS.label

end