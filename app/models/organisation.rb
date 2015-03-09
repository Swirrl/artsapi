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

    # takes a uri object or string
    def write_link(org_one, org_two)
      org_one = Organisation.find(org_one)
      org_two = Organisation.find(org_two)

      org_one.linked_to = org_one.linked_to + [org_two.uri] # write org:linkedTo
      org_two.linked_to = org_two.linked_to + [org_one.uri] # write org:linkedTo

      begin
        org_one.save!
        org_two.save!
      rescue
        false
      end
    end

  end

end