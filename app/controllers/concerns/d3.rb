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
    attr_accessor :organisation, :formatted_hash, :org_mapping

    def initialize(org)
      self.bootstrap_hash_and_mapping
      self.organisation = org
      self.collect_all_organisations
    end

    def bootstrap_hash_and_mapping
      self.formatted_hash = {}
      self.org_mapping = {}

      self.formatted_hash["nodes"] = []
      self.formatted_hash["links"] = []
    end

    def collect_all_organisations
      self.organisation.linked_to.each do |other_org|
        self.add_to_hash(other_org, type: :organisation)
        self.collect_all_connections(other_org.to_s)
      end
    end

    def collect_all_connections(organisation_uri)
      members = Organisation.find(organisation_uri).has_members

      members.each do |member|
        self.add_to_hash(member, type: :member)
      end
    end

    def add_to_hash(uri, opts={})
      type = opts.fetch(:type, :member)
      # if not in mapping, add to hash

      # else, do nothing
    end

  end

end