class Organisation

  include Tripod::Resource

  rdf_type 'http://www.w3.org/ns/org#Organization'
  graph_uri 'http://artsapi.com/graph/organisations'

  field :label, RDF::RDFS.label
  field :has_members, RDF::ORG['hasMember'], is_uri: true, multivalued: true
  field :linked_to, RDF::ORG['linkedTo'], is_uri: true, multivalued: true
  field :owns_domain, RDF::ARTS['ownsDomain'], is_uri: true
  field :works_on, RDF::ARTS['worksOn'], is_uri: true, multivalued: true

  class << self

    def write_link(org_one, org_two)
      org_one.write_predicate() # write org:linkedTo
      org_two.write_predicate() # write org:linkedTo
    end

  end

end