class KeywordCategory

  include Tripod::Resource

  # @prefix keywordcategory: <http://data.artsapi.com/id/keywords/category/> .

  rdf_type 'http://data.artsapi.com/def/arts/keywords/Category'
  graph_uri 'http://data.artsapi.com/graph/keywords'

  field :label, RDF::RDFS.label

  # override to use correct db
  def find(uri, opts={})
    User.current_user.within do
      super(uri, opts)
    end
  end

end