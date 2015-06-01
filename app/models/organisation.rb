require 'memoist'
class Organisation < ResourceWithPresenter

  include Tripod::Resource
  extend TripodOverrides
  extend Memoist

  rdf_type 'http://www.w3.org/ns/org#Organization'
  graph_uri 'http://data.artsapi.com/graph/organisations'

  field :label, RDF::RDFS.label
  field :has_members, RDF::ORG['hasMember'], is_uri: true, multivalued: true
  field :linked_to, RDF::ORG['linkedTo'], is_uri: true, multivalued: true
  field :owns_domain, RDF::ARTS['ownsDomain'], is_uri: true
  field :works_on, RDF::ARTS['worksOn'], is_uri: true, multivalued: true

  field :graph_visualisation, RDF::ARTS['visualisation']

  # sic uri or extension
  field :sector, RDF::ARTS['sector'], is_uri: true

  # for location
  field :country, RDF::ARTS['locationCountry']
  field :city, RDF::ARTS['locationCity']

  # for heuristics
  field :common_subject_areas, RDF::ARTS['commonSubjectArea'], is_uri: true, multivalued: true
  field :common_keywords, RDF::ARTS['commonKeyword'], is_uri: true, multivalued: true

  def get_visualisation_graph
    if !self.graph_visualisation.nil?
      # expensive, not sure we want to do this
      set_visualisation_graph_async if Rails.env.production?
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

    User.add_job_for_current_user(job_id)

    job_id
  end

  def sector_label
    SICConcept.find_class_or_subclass(self.sector).label rescue nil
  end

  def location_string
    "City: #{self.city || "Not known"}, Country: #{self.country || "Not known"}"
  end

  def get_top_subject_areas
    members = self.has_members.map { |uri| Person.find(uri) }

    areas = members.map(&:get_or_generate_subject_area!).flatten

    counter = {}

    areas.each do |subject_area|
      if counter.has_key?(subject_area)
        counter[subject_area] += 1
      else
        counter[subject_area] = 1
      end
    end

    counter.sort { |a, b| b[1] <=> a[1] }[0..2]
  end

  def get_common_subject_areas!
    common_subjects = get_top_subject_areas.map { |subj| subj[0] }.compact

    self.common_subject_areas = common_subjects
    self.save

    common_subjects
  end

  def get_top_keywords
    members = self.has_members.map { |uri| Person.find(uri) }

    keyword_lists = members.map(&:sorted_keywords)

    counter = {}

    keyword_lists.each do |list|
      list.each do |keyword_entry|
        if counter.has_key?(keyword_entry[0])
          counter[keyword_entry[0]] += keyword_entry[1]
        else
          counter[keyword_entry[0]] = keyword_entry[1]
        end
      end
    end

    counter.sort { |a, b| b[1] <=> a[1] }[0..9]
  end

  def get_common_keywords!
    top_ten_common_words = get_top_keywords.map { |kw| Keyword.uri_from_label(kw[0]) }

    self.common_keywords = top_ten_common_words
    self.save

    top_ten_common_words
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

    organisation_level_connections.flatten
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

  def force_regenerate_email_counts!
    self.has_members.each do |member_uri|
      p = Person.find(member_uri)
      p.number_of_incoming_emails(true)
      p.number_of_sent_emails(true)
    end
  end

  def members_with_more_than_x_connections(x)
    self.has_members.map { |m| m if Person.find(m).connections.length > x }.compact
  end
  memoize :members_with_more_than_x_connections

  # look at extension and take a punt
  def best_guess_at_country
    return self.country if !self.country.nil?

    extension_possibilities = []
    extension_possibilities << ".#{self.uri.to_s.gsub(/^.+organisations\/.+\-/, '')}"
    extension_possibilities << self.uri.to_s.gsub(/^.+organisations\/[A-z]+/, '').gsub(/\-/, '.')
    extension_possibilities << self.uri.to_s.match(/\-[A-z]+\-[A-z]+$/)[0].gsub(/\-/, '.') rescue ''
    mapping = ArtsAPI::COUNTRIES_MAPPING

    result = nil
    extension_possibilities.each { |ex| result = mapping[ex] if mapping.has_key?(ex) }

    if !result.nil?
      self.country = result
      self.save
    end

    result
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

    # from a form
    def bootstrap_connections_and_vis_for(uri)
      organisation = Organisation.find(uri)

      job_ids = []
      job_ids << organisation.generate_connections_async!
      job_ids << organisation.generate_visualisations_async!

      job_ids
    end

    # for when you absolutely, positively need to process every dataset in the room
    # bear in mind that async-ness might cause problems in the end anyway
    def bootstrap_all!
      User.bootstrap_sic_for_current_user!
      User.bootstrap_keywords_for_current_user!

      organisations = Organisation.all.resources

      job_ids = []

      organisations.each do |org|
        job_ids << bootstrap_connections_and_vis_for(org.uri)
      end

      job_ids
    end

    # first, try and extract the owning org from current signed in user, else
    # a more pragmatic version; the Org with the largest number of links
    # will almost certainly be the owner organisation, and running through
    # only their members will save a ton of processing
    def bootstrap_owner_or_largest_org!
      begin
        User.bootstrap_sic_for_current_user!
        User.bootstrap_keywords_for_current_user!

        owner_org = User.current_user.find_org_from_self_in_data

        owner_org.generate_connections_async!
        owner_org.generate_visualisations_async!

        # we may need to make this async
        owner_org.force_regenerate_email_counts!

      rescue # couldn't find either person or org

        bootstrap_all!

        # this would be nice, but it times out
        # organisations = Organisation.all.resources

        # # generate connections
        # organisations.each { |org| org.generate_all_connections! }

        # # need to reload orgs
        # most_linked_org = Organisation.all.resources.sort { |a,b| b.linked_to.count <=> a.linked_to.count }.first

        # most_linked_org.generate_visualisations_async!

      end
    end

  end

end