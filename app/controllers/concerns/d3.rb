module D3

  extend ActiveSupport::Concern

  # here be dragons!
  # construct a correctly formatted hash
  # that will be acceptable to d3
  def self.format_for_d3(person, conn_array)
    conn_hash = {}

    person_mapping = {}

    conn_hash["nodes"] = []
    conn_hash["links"] = []

    person_uri = person.uri.to_s
    person_mapping[person_uri] = 0
    person_counter = 1

    # bootstrap the self element
    person_member_of = person.member_of.to_s
    conn_hash["nodes"] << {id: 0, name: person.human_name, group: person_member_of}

    conn_array.each do |conn|
      begin
        p = Person.find(conn[0])
        name = p.human_name

        org = p.member_of.to_s
        uri = p.uri.to_s

        if !person_mapping.has_key?(uri)
          person_mapping[uri] = person_counter
          person_counter += 1
        end

        connections = p.sorted_email_density
        conn_hash, person_mapping, person_counter = self.return_connections_nodes_for(p, connections, conn_hash, person_mapping, person_counter)

        conn_hash["nodes"] << {
          id: person_mapping[uri],
          name: name,
          group: org
        }

        conn_hash["links"] << {
          source: person_mapping[uri],
          target: person_mapping[person_uri],
          value: conn[1]
        }

      rescue
        # do not add the node
      end
    end

    conn_hash
  end

  def self.return_connections_nodes_for(person, conn_array, conn_hash, person_mapping, person_counter)

    person_uri = person.uri.to_s
    person_member_of = person.member_of.to_s

    conn_array.each do |conn|
      begin
        p = Person.find(conn[0])
        name = p.human_name

        org = p.member_of.to_s
        uri = p.uri.to_s

        if !person_mapping.has_key?(uri)
          person_mapping[uri] = person_counter
          person_counter += 1
        end

        conn_hash["nodes"] << {
          id: person_mapping[uri],
          name: name,
          group: org
        }

        conn_hash["links"] << {
          source: person_mapping[uri],
          target: person_mapping[person_uri],
          value: conn[1]
        }

      rescue
        # do not add the node
      end
    end

    [conn_hash, person_mapping, person_counter]
  end

end