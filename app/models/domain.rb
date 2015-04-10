class Domain < ResourceWithPresenter

  include Tripod::Resource

  rdf_type 'http://data.artsapi.com/def/arts/Domain'
  graph_uri 'http://data.artsapi.com/graph/domains'

  field :label, RDF::RDFS.label
  field :has_url, RDF::VCARD['hasUrl']

end