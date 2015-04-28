class Domain < ResourceWithPresenter

  include Tripod::Resource

  rdf_type 'http://data.artsapi.com/def/arts/Domain'
  graph_uri 'http://data.artsapi.com/graph/domains'

  field :label, RDF::RDFS.label
  field :has_url, RDF::VCARD['hasUrl']

  # override to use correct db
  def find(uri, opts={})
    User.current_user.within do
      super(uri, opts)
    end
  end

end