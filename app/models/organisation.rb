class Organisation

  include Resource

  rdf_type 'http://www.w3.org/ns/org#Organisation'
  graph_uri 'http://artsapi.com/graph/organisations'

  field :label, RDF::RDFS.label
  field :has_member, RDF::ORG['hasMember']
  field :linked_to, RDF::ORG['linkedTo']
  field :owns_domain, RDF::ARTS['ownsDomain']
  field :works_on, RDF::ARTS['worksOn']

end