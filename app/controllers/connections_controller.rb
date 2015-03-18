class ConnectionsController < ApplicationController

  def find
    uri = params[:uri]

    respond_to do |format|
      format.json {
        begin
          connections = Person.find(uri).connections
          render json: {connections: connections}, status: 200
        rescue
          render json: {text: 'Resource not found.'}, status: 404
        end
      }
    end
  end

  def schedule
    uri = params[:uri]

    respond_to do |format|
      format.json {
        begin
          Person.find(uri).generate_connections_async
          render json: {text: 'Scheduled.'}, status: 202
        rescue
          render json: {text: 'Something went wrong.'}, status: 404
        end
      }
    end
  end

  def visualise
    uri = params[:uri]

    #respond_to do |format|
      #format.json {
        begin
          person_to_visualise = Person.find(uri)
          connections = format_for_d3(person_to_visualise, person_to_visualise.sorted_email_density)
          render json: connections.to_json, status: 200
        rescue => e
          render json: {text: 'Resource not found.'}, status: 404
        end
      #}
    #end
  end

  private

  # here be dragons!
  # construct a correctly formatted hash
  # that will be acceptable to d3
  def format_for_d3(person, conn_array)
    conn_hash = {}
    organisations = {}

    conn_hash["nodes"] = []
    conn_hash["links"] = []

    # bootstrap the self element
    conn_hash["nodes"] << {id: 0, name: person.human_name, group: 0}
    person_member_of = person.member_of.to_s
    organisations[person_member_of] = [0, 1]
    conn_hash["nodes"] << {id: 1, name: person_member_of, group: 0}
    conn_hash["links"] << {source: 1, target: 0, value: 1}

    source_counter = 2
    group_counter = 1

    conn_array.each do |conn|
      begin
        p = Person.find(conn[0])
        name = p.human_name

        org = p.member_of.to_s

        if organisations.has_key?(org)
          group = organisations[org][0]
          org_id = organisations[org][1]

          conn_hash["links"] << {
            source: org_id,
            target: source_counter,
            value: 1
          }
        else
          organisations[org] = [group_counter, source_counter]
          group = group_counter

          conn_hash["nodes"] << {
            id: source_counter,
            name: org,
            group: group
          }

          conn_hash["links"] << {
            source: source_counter,
            target: source_counter + 1,
            value: 1
          }

          source_counter += 1
          group_counter += 1
        end

        conn_hash["nodes"] << {
          id: source_counter,
          name: name,
          group: group
        }

        conn_hash["links"] << {
          source: source_counter,
          target: 0,
          value: conn[1]
        }

        source_counter += 1
      rescue
        # do not add the node
      end
    end

    conn_hash
  end

end