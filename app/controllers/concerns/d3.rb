module D3

  extend ActiveSupport::Concern

  # here be dragons!
  # construct a correctly formatted hash
  # that will be acceptable to d3
  class ConnectionsGraph
    attr_accessor :person_mapping, :conn_hash

    def initialize(person, conn_array)
      self.bootstrap_hash_and_mapping

      person_uri = person.uri.to_s
      self.person_mapping[person_uri] = 0
      person_counter = 1

      # bootstrap the self element
      person_member_of = person.member_of.to_s
      self.conn_hash["nodes"] << {id: 0, name: person.human_name, uri: person_uri, group: person_member_of}

      # work out how deep the rabbit hole goes
      # 1 is a sensible setting if using naive binning, otherwise use a much higher number (e.g. 8)
      initial_bin_threshold = 1
      filtered_connections = self.filter_connections(conn_array, initial_bin_threshold)

      filtered_connections.each do |conn|

        person_counter = self.add_to_hash(conn[0], conn[1], person_uri, person_counter, (initial_bin_threshold + 1))

      end
    end

    def bootstrap_hash_and_mapping
      self.conn_hash = {}
      self.person_mapping = {}

      self.conn_hash["nodes"] = []
      self.conn_hash["links"] = []
    end

    def filter_connections(conn_array, bin_cutoff, opts={})
      use_naive = opts.fetch(:use_naive, true)

      highest_value = conn_array.first[1].to_f
      lowest_value = conn_array.last[1].to_f

      if use_naive
        naive_bin_size = (highest_value - lowest_value) / 10
        filter_threshold = (naive_bin_size * bin_cutoff) + lowest_value
      else
        bin_size_by_length = (conn_array.length / 10)
        filter_threshold = conn_array[(bin_size_by_length * bin_cutoff).to_i][1]
      end

      conn_array.map { |a| a if a[1] > filter_threshold }.compact
    end

    def add_to_hash(uri, value, target_uri, person_counter, bin_cutoff)

      if !person_mapping.has_key?(uri)
        p = Person.find(uri)
        name = p.human_name

        org = p.member_of.to_s
        conn_array = p.sorted_email_density

        self.person_mapping[uri] = person_counter
        person_counter += 1

        self.conn_hash["nodes"] << {
          id: self.person_mapping[uri],
          name: name,
          uri: uri,
          group: org
        }
      end

      self.conn_hash["links"] << {
        source: self.person_mapping[uri],
        target: self.person_mapping[target_uri],
        value: value
      }

      if bin_cutoff < 10 && !conn_array.nil?
        filtered = self.filter_connections(conn_array, bin_cutoff)

        filtered.each { |conn| person_counter = self.add_to_hash(conn[0], conn[1], uri, person_counter, (bin_cutoff + 1)) }
      end

      return person_counter

    end
  end

  class OrganisationsGraph
    attr_accessor :organisation, :formatted_hash, :org_mapping, :counter

    def initialize(org)
      self.bootstrap_hash_and_mapping
      self.counter = 1
      self.organisation = org
      self.collect_all_organisations
    end

    def bootstrap_hash_and_mapping
      self.formatted_hash = {}
      self.org_mapping = {}

      self.org_mapping[:members] = {}
      self.org_mapping[:organisations] = {}

      self.formatted_hash["nodes"] = []
      self.formatted_hash["links"] = []
    end

    def collect_all_organisations
      org_uri = self.organisation.uri
      add_to_hash(org_uri, type: :organisation)
      collect_all_connections(org_uri.to_s)

      organisation_links = self.organisation.linked_to

      organisation_links.each do |other_org_uri|
        add_to_hash(other_org_uri, type: :organisation)
        add_all_members(other_org_uri.to_s)
      end

      self.add_all_links(org_uri.to_s)
      organisation_links.each { |other_org_uri| add_all_links(other_org_uri.to_s) }
    end

    def add_all_members(organisation_uri)
      members = Organisation.find(organisation_uri).has_members

      members.each do |member|
        add_to_hash(member, type: :member)
      end
    end

    def add_to_hash(uri, opts={})
      type = opts.fetch(:type, :member)
      uri = uri.to_s # make sure it isn't an RDF::URI

      if type == :member
        if !self.org_mapping[:members].has_key?(uri)
          m, id = lookup_and_add_member_node(uri.to_s)

          m.connections.each do |conn|
            lookup_and_add_member_node(conn.to_s)

            conn_id = self.org_mapping[:members][conn.to_s]
            add_link!(id, conn_id, 1)
          end
        end
      elsif type == :organisation
        if !self.org_mapping[:organisations].has_key?(uri)
          id = self.counter
          self.org_mapping[:organisations][uri] = id

          add_node!(id, uri, uri, uri)
          increment_counter!
        end
      end
    end

    def add_all_links(organisation_uri)
      add_links_for(organisation_uri)
      organisation_links.each { |other_org_uri| add_links_for(other_org_uri.to_s) }
    end

    def add_links_for(organisation_uri)
      org = Organisation.find(organisation_uri)
      org_id = self.org_mapping[:organisations][organisation_uri]

      org.linked_to.each do |other_org_uri|
        other_org_id = self.org_mapping[:organisations][other_org_uri.to_s]
        add_link!(org_id, other_org_id, 1)
      end
    end

    def lookup_and_add_member_node(uri)
      m = Person.find(uri)
      id = self.counter
      self.org_mapping[:members][uri] = id

      add_node!(id, m.human_name, uri, m.member_of.to_s)
      increment_counter!
      [m, id]
    end

    def add_node!(id, name, uri, group)
      self.formatted_hash["nodes"] << {
        id: id,
        name: name,
        uri: uri,
        group: group
      }
    end

    def add_link!(source, target, value)
      self.formatted_hash["links"] << {
        source: source,
        target: target,
        value: value
      }
    end

    def increment_counter!
      self.counter = self.counter + 1
    end

  end

end