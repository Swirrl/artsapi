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
      add_all_members(org_uri.to_s)

      organisation_links = self.organisation.linked_to

      organisation_links.each do |other_org_uri|
        add_to_hash(other_org_uri, type: :organisation)
        add_all_members(other_org_uri.to_s)
      end
    end

    def add_all_members(organisation_uri)
      org = Organisation.find(organisation_uri)
      members = org.has_members
      org_id = self.org_mapping[:organisations][org.uri.to_s]

      members.each do |member|
        add_to_hash(member, type: :member)

        member_id = self.org_mapping[:members][member.to_s]
        add_link!(org_id, member_id, 1)
      end
    end

    def add_to_hash(uri, opts={})
      type = opts.fetch(:type, :member)
      uri = uri.to_s # make sure it isn't an RDF::URI

      if type == :member
        if !self.org_mapping[:members].has_key?(uri)
          m, id = lookup_and_add_member_node(uri.to_s)

          m.connections.each do |conn|
            lookup_and_add_member_node(conn.to_s) if !self.org_mapping[:members].has_key?(conn.to_s)

            conn_id = self.org_mapping[:members][conn.to_s]
            add_link!(id, conn_id, 10)
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

    def lookup_and_add_member_node(uri)
      m = Person.find(uri)
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

      add_node!(id, uri, uri, uri)
      increment_counter!
      [o, id]
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