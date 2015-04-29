module D3

  extend ActiveSupport::Concern

  class OrganisationsGraph
    attr_accessor :organisation, :formatted_hash, :org_mapping, :counter

    def initialize(org)
      self.bootstrap_hash_and_mapping
      self.counter = 0
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

      org = Organisation.find(org_uri)
      members = org.has_members
      add_all_members(org, members)

      organisation_links = self.organisation.linked_to

      organisation_links.each do |other_org_uri|
        add_org_and_members_if_relevant(other_org_uri)
      end
    end

    # we want to get rid of gmail, hotmail etc
    def is_red_herring?(uri)
      org_data_root = "http://data.artsapi.com/id/organisations/"

      !!([
        "#{org_data_root}hotmail-com",
        "#{org_data_root}hotmail-co-uk",
        "#{org_data_root}live-com",
        "#{org_data_root}live-co-uk",
        "#{org_data_root}outlook-com",
        "#{org_data_root}outlook-co-uk",
        "#{org_data_root}gmail-com",
        "#{org_data_root}gmail-co-uk",
        "#{org_data_root}googlemail-com",
        "#{org_data_root}googlemail-co-uk"
        ].include?(uri))
    end

    def add_org_and_members_if_relevant(other_org_uri)
      if !is_red_herring?(other_org_uri)
        organisation_object = Organisation.find(other_org_uri)

        # only hammer through members if org has a few
        members = organisation_object.has_members

        if members.length > 1
          add_to_hash(other_org_uri, type: :organisation)
          add_all_members(organisation_object, members)
        end
      end
    end

    def add_all_members(organisation_object, members)
      org_id = self.org_mapping[:organisations][organisation_object.uri.to_s]

      members.each do |member|
        if Person.find(member).connections.length > 0
          add_to_hash(member, type: :member)

          member_id = self.org_mapping[:members][member.to_s]
          add_link!(org_id, member_id, 1)
        end
      end

    end

    def add_to_hash(uri, opts={})
      type = opts.fetch(:type, :member)
      uri = uri.to_s # make sure it isn't an RDF::URI

      if type == :member
        if !self.org_mapping[:members].has_key?(uri)

          m, id = lookup_and_add_member_node(uri.to_s)

          m.connections.each do |conn|

            if !member_in_org_mapping?(conn.to_s)
              p = Person.find(conn.to_s)
              if relevant?(p)
                lookup_and_add_member_node(conn.to_s, person: p) 

                conn_id = self.org_mapping[:members][conn.to_s]
                add_link!(id, conn_id, 10)
              end
            else
              conn_id = self.org_mapping[:members][conn.to_s]
              add_link!(id, conn_id, 10)
            end

          end
        else # they might be in the mapping, but are their connections?

          m = Person.find(uri)
          id = self.org_mapping[:members][uri]

          m.connections.each do |conn|

            if !member_in_org_mapping?(conn.to_s)
              p = Person.find(conn.to_s) 
              if relevant?(p)
                lookup_and_add_member_node(conn.to_s, person: p)

                conn_id = self.org_mapping[:members][conn.to_s]
                add_link!(id, conn_id, 10)
              end
            else
              conn_id = self.org_mapping[:members][conn.to_s]
              add_link!(id, conn_id, 10)
            end

          end
        end
      elsif type == :organisation
        if !self.org_mapping[:organisations].has_key?(uri)
          o, id = lookup_and_add_org_node(uri.to_s)

          o.linked_to.each do |org_uri|
            lookup_and_add_org_node(org_uri.to_s) if !self.org_mapping[:organisations].has_key?(org_uri.to_s)

            link_id = self.org_mapping[:organisations][org_uri.to_s]
            add_link!(id, link_id, 10)
          end
        end
      end
    end

    def member_in_org_mapping?(member)
      !!(self.org_mapping[:members].has_key?(member.to_s))
    end

    def relevant?(person_object)
      linked_orgs = self.organisation.linked_to

      !!(person_object.connections.length > 1 && linked_orgs.include?(person_object.member_of.to_s) && !is_red_herring?(person_object.member_of.to_s))
    end

    def lookup_and_add_member_node(uri, opts={})
      m = opts.fetch(:person, nil)
      m = Person.find(uri) if m.nil?
      id = self.counter
      self.org_mapping[:members][uri] = id

      add_node!(id, m.human_name, uri, m.member_of.to_s)
      increment_counter!
      [m, id]
    end

    def lookup_and_add_org_node(uri)
      o = Organisation.find(uri)
      id = self.counter
      self.org_mapping[:organisations][uri] = id

      add_node!(id, uri, uri, uri, is_org: true)
      increment_counter!
      [o, id]
    end

    def add_node!(id, name, uri, group, opts={})
      is_org = opts.fetch(:is_org, false)

      node = {
        id: id,
        name: name,
        uri: uri,
        group: group
      }

      node[:org] = true if is_org
      self.formatted_hash["nodes"] << node
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