class Domain

  include Resource

  rdf_type 'http://artsapi.com/def/arts/Domain'
  graph_uri 'http://artsapi.com/graph/domains'

  field :label, RDF::RDFS.label
  field :has_url, RDF::VCARD['hasUrl']

end