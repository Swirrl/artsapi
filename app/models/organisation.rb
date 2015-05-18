require 'memoist'
class Organisation < ResourceWithPresenter

  include Tripod::Resource
  include TripodOverrides
  extend Memoist

  rdf_type 'http://www.w3.org/ns/org#Organization'
  graph_uri 'http://data.artsapi.com/graph/organisations'

  field :label, RDF::RDFS.label
  field :has_members, RDF::ORG['hasMember'], is_uri: true, multivalued: true
  field :linked_to, RDF::ORG['linkedTo'], is_uri: true, multivalued: true
  field :owns_domain, RDF::ARTS['ownsDomain'], is_uri: true
  field :works_on, RDF::ARTS['worksOn'], is_uri: true, multivalued: true

  field :graph_visualisation, RDF::ARTS['visualisation']

  def get_visualisation_graph
    if !self.graph_visualisation.nil?
      # set_visualisation_graph_async expensive, we don't want to do this
      JSON.parse(sanitize_json(self.graph_visualisation))
    else
      graph_json = D3::OrganisationsGraph.new(self).formatted_hash
      set_visualisation_graph(graph_json)
      graph_json
    end
  end

  def set_visualisation_graph(hash)
    self.graph_visualisation = hash.to_json
    self.save
  end

  def set_visualisation_graph_async
    current_user_id = User.current_user.id.to_s
    job_id = ::OrganisationsWorker.perform_in(50.seconds, self.uri.to_s, current_user_id)

    User.current_user.job_ids << job_id
    User.current_user.save

    job_id
  end

  def sanitize_json(string)
    string.strip
      .gsub(/(?:\\n)/, '')
      .gsub(/(?:\\r)/, '')
      .gsub(/\r/, '')
      .gsub(/\n/, '')
      .gsub(/\\n/, '')
      .gsub(/\\/, '')
  end

  # (re)generate connections for all members of an organisation
  def generate_all_connections!
    organisation_level_connections = []

    self.has_members.each do |member_uri|
      member = Person.find(member_uri)
      organisation_level_connections << member.get_connections!
    end

    organisation_level_connections.flatten.uniq
  end

  def generate_connections_async!
    job_ids = []

    self.has_members.each do |member_uri|
      member = Person.find(member_uri)
      job_ids << member.generate_connections_async
    end

    job_ids
  end

  def generate_visualisations_async!
    job_ids = []

    self.has_members.each do |member_uri|
      member = Person.find(member_uri)
      job_ids << member.set_visualisation_graph_async
    end

    job_ids << self.set_visualisation_graph_async

    job_ids
  end

  def members_with_more_than_x_connections(x)
    self.has_members.map { |m| m if Person.find(m).connections.length > x }.compact
  end
  memoize :members_with_more_than_x_connections

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

    # from a form
    def bootstrap_connections_and_vis_for(uri)
      organisation = Organisation.find(uri)

      job_ids = []
      job_ids << organisation.generate_connections_async!
      job_ids << organisation.generate_visualisations_async!

      job_ids
    end

    # for when you absolutely, positively need to process every dataset in the room
    def bootstrap_all!
      organisations = Organisation.all.resources

      job_ids = []

      organisations.each do |org|
        job_ids << bootstrap_connections_and_vis_for(org.uri)
      end

      job_ids
    end

  end

end