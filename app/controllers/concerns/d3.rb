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

      conn_hash, person_mapping, person_counter = self.add_to_hash(conn[0], conn[1], person_uri, conn_hash, person_mapping, person_counter)

    end

    #conn_hash = add_organisational_links_for(conn_array, conn_hash, person_mapping, person_counter)

    conn_hash
  end

  def self.return_connections_nodes_for(person, conn_array, conn_hash, person_mapping, person_counter)

    person_uri = person.uri.to_s
    person_member_of = person.member_of.to_s

    conn_array.each do |conn|

      conn_hash, person_mapping, person_counter = self.add_to_hash(conn[0], conn[1], person_uri, conn_hash, person_mapping, person_counter)

    end

    [conn_hash, person_mapping, person_counter]
  end

  def self.add_organisational_links_for(conn_array, conn_hash, person_mapping, person_counter)

    mapped_orgs = []

    conn_array.each do |conn|
      p = Person.find(conn[0])
      org = p.member_of.to_s

      begin
        if !mapped_orgs.include?(org)
          colleagues = p.get_colleagues.map(&:to_s)

          if !colleagues.empty?‹
            colleagues.each do |colleague|

              # make sure nodes for colleagues exist
              if !person_mapping.has_key?(colleague)
                person_mapping[colleague.to_s] = person_counter
                person_counter += 1

                conn_hash["nodes"] << {
                  id: person_mapping[colleague],
                  name: name,
                  group: org
                }
              end

            end

            # make sure they link to one another
            conn_hash = self.write_reciprocal_links(colleagues, conn_hash, person_mapping)
          end

          mapped_orgs << org
        end
      rescue Exception => e
        puts "\n\n\n\n\n\n#{e.inspect}\n#{e.backtrace.join("\n")}\n\n\n\n\n\n\n\n"
      end

    end

    conn_hash
  end

  def self.write_reciprocal_links(colleagues, conn_hash, person_mapping)

    colleagues.each do |colleague|
      colleagues.each do |c|

        conn_hash["links"] << {
          source: person_mapping[colleague],
          target: person_mapping[c],
          value: 1
        }

        conn_hash["links"] << {
          source: person_mapping[c],
          target: person_mapping[colleague],
          value: 1
        }

      end
    end

    conn_hash
  end


  def self.add_to_hash(uri, value, target_uri, conn_hash, person_mapping, person_counter)
    begin
      p = Person.find(uri)
      name = p.human_name

      org = p.member_of.to_s
      uri = p.uri.to_s

      if !person_mapping.has_key?(uri)
        person_mapping[uri] = person_counter
        person_counter += 1
      end

      #connections = p.sorted_email_density
      #conn_hash, person_mapping, person_counter = self.return_connections_nodes_for(p, connections, conn_hash, person_mapping, person_counter)

      conn_hash["nodes"] << {
        id: person_mapping[uri],
        name: name,
        group: org
      }

      conn_hash["links"] << {
        source: person_mapping[uri],
        target: person_mapping[target_uri],
        value: value
      }

    rescue
      # do not add the node
    end

    [conn_hash, person_mapping, person_counter]
  end

end