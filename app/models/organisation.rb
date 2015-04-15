class Organisation < ResourceWithPresenter

  include Tripod::Resource

  rdf_type 'http://www.w3.org/ns/org#Organization'
  graph_uri 'http://data.artsapi.com/graph/organisations'

  field :label, RDF::RDFS.label
  field :has_members, RDF::ORG['hasMember'], is_uri: true, multivalued: true
  field :linked_to, RDF::ORG['linkedTo'], is_uri: true, multivalued: true
  field :owns_domain, RDF::ARTS['ownsDomain'], is_uri: true
  field :works_on, RDF::ARTS['worksOn'], is_uri: true, multivalued: true

  # (re)generate connections for all members of an organisation
  # takes an rdf uri or uri as a string
  def generate_all_connections!
    organisation_level_connections = []

    self.has_members.each do |member_uri|
      member = Person.find(member_uri)
      organisation_level_connections << member.generate_connections_async
    end

    organisation_level_connections.flatten.uniq
  end

  class << self

    # takes a uri object or string
    def write_link(org_one, org_two)
      org_one = Organisation.find(org_one)
      org_two = Organisation.find(org_two)

      if org_one != org_two
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

end