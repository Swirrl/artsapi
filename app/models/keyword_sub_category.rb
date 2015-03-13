class KeywordSubCategory

  include Tripod::Resource

  # @prefix keywordsubcategory: <http://artsapi.com/id/keywords/subcategory/> .

  rdf_type 'http://artsapi.com/def/arts/keywords/KeywordSubCategory'
  graph_uri 'http://artsapi.com/def/arts/keywords/keywords'

  field :label, RDF::RDFS.label
  field :in_category, 'http://artsapi.com/def/arts/keywords/inCategory', is_uri: true

end