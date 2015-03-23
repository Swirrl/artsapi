module D3

  extend ActiveSupport::Concern

  # here be dragons!
  # construct a correctly formatted hash
  # that will be acceptable to d3
  def self.format_graph_for_d3(person, conn_array)
    conn_hash = {}

    person_mapping = {}

    conn_hash["nodes"] = []
    conn_hash["links"] = []

    person_uri = person.uri.to_s
    person_mapping[person_uri] = {id: 0, connections: conn_array}
    person_counter = 1

    # bootstrap the self element
    person_member_of = person.member_of.to_s
    conn_hash["nodes"] << {id: 0, name: person.human_name, group: person_member_of}

    # work out how deep the rabbit hole goes
    initial_bin_threshold = 3
    filtered_connections = self.filter_connections(conn_array, initial_bin_threshold)

    filtered_connections.each do |conn|

      conn_hash, person_mapping, person_counter = self.add_to_hash(conn[0], conn[1], person_uri, conn_hash, person_mapping, person_counter, (initial_bin_threshold + 1))

    end

    conn_hash
  end

  def self.filter_connections(conn_array, bin_cutoff)
    highest_value = conn_array.first[1].to_f
    lowest_value = conn_array.last[1].to_f

    naive_bin_size = (highest_value - lowest_value) / 10
    filter_threshold = (naive_bin_size * bin_cutoff) + lowest_value

    conn_array.map { |a| a if a[1] > filter_threshold }.compact
  end

  # todo: memoize so you don't need to lookup person and call sort on each
  def self.add_to_hash(uri, value, target_uri, conn_hash, person_mapping, person_counter, bin_cutoff)

    if bin_cutoff >= 10

      p = Person.find(uri)
      name = p.human_name

      org = p.member_of.to_s

      if !person_mapping.has_key?(uri)
        person_mapping[uri] = {id: person_counter}
        person_counter += 1

        conn_hash["nodes"] << {
          id: person_mapping[uri][:id],
          name: name,
          group: org
        }
      end

      conn_hash["links"] << {
        source: person_mapping[uri][:id],
        target: person_mapping[target_uri][:id],
        value: value
      }

      return [conn_hash, person_mapping, person_counter]
    else
      begin
        p = Person.find(uri)
        name = p.human_name

        org = p.member_of.to_s

        if !person_mapping.has_key?(uri)
          conn_array = p.sorted_email_density

          person_mapping[uri] = {id: person_counter, connections: conn_array}
          person_counter += 1

          conn_hash["nodes"] << {
            id: person_mapping[uri][:id],
            name: name,
            group: org
          }
        else
          conn_array = person_mapping[uri][:connections]
        end

        conn_hash["links"] << {
          source: person_mapping[uri][:id],
          target: person_mapping[target_uri][:id],
          value: value
        }

        filtered_connections = self.filter_connections(conn_array, bin_cutoff)

        filtered_connections.each do |conn|

          conn_hash, person_mapping, person_counter = self.add_to_hash(conn[0], conn[1], uri, conn_hash, person_mapping, person_counter, (bin_cutoff + 2))

        end

      rescue
        # do not add the node
      end

      return [conn_hash, person_mapping, person_counter]
    end
  end

end