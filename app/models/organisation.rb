class Organisation

  include Tripod::Resource

  rdf_type 'http://www.w3.org/ns/org#Organisation'
  graph_uri 'http://artsapi.com/graph/organisations'

  field :label, RDF::RDFS.label
  field :has_member, RDF::ORG['hasMember'], is_uri: true
  field :linked_to, RDF::ORG['linkedTo'], is_uri: true
  field :owns_domain, RDF::ARTS['ownsDomain'], is_uri: true
  field :works_on, RDF::ARTS['worksOn'], is_uri: true

end