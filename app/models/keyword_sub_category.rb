class KeywordSubCategory

  include Tripod::Resource

  # @prefix keywordsubcategory: <http://data.artsapi.com/id/keywords/subcategory/> .

  rdf_type 'http://data.artsapi.com/def/arts/keywords/KeywordSubCategory'
  graph_uri 'http://data.artsapi.com/graph/keywords'

  field :label, RDF::RDFS.label
  field :in_category, 'http://data.artsapi.com/def/arts/keywords/inCategory', is_uri: true

  # override to use correct db
  def find(uri, opts={})
    User.current_user.within do
      super(uri, opts)
    end
  end

end