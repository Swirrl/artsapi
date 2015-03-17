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
        rescue
          render json: {text: 'Resource not found.'}, status: 404
        end
      #}
    #end
  end

  private

  def format_for_d3(person, conn_array)
    conn_hash = {}
    organisations = {}

    conn_hash["nodes"] = []
    conn_hash["links"] = []

    # bootstrap the self element
    conn_hash["nodes"] << {name: person.name, group: 1}
    organisations[person.member_of.to_s] = 1

    source_counter = 2
    group_counter = 2

    conn_array.each do |conn|
      p = Person.find(conn[0])
      name = p.human_name

      org = p.member_of.to_s

      if organisations.has_key?(org)
        group = organisations[org]
      else
        organisations[org] = group_counter
        group = group_counter
        group_counter += 1
      end

      conn_hash["nodes"] << {
        name: name,
        group: group
      }

      conn_hash["links"] << {
        source: source_counter,
        target: 1,
        value: conn[1]
      }

      source_counter += 1
    end

    conn_hash
  end

end