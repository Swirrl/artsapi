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
          render json: {text: 'Sorry, something went wrong. Please check the logs for details.'}, status: 404
        end
      }
    end
  end

  def visualise
    uri = params[:uri]

    begin
      person_to_visualise = Person.find(uri)
      connections = D3::ConnectionsGraph.new(person_to_visualise).conn_hash
      render json: connections.to_json, status: 200
    rescue => e
      render json: {text: 'Sorry, something went wrong. Please check the logs for details.'}, status: 404
    end

  end

  def visualise_organisation
    uri = params[:uri]

    begin
      org_to_visualise = Organisation.find(uri)
      formatted_hash = D3::OrganisationsGraph.new(org_to_visualise).formatted_hash
      render json: formatted_hash.to_json, status: 200
    rescue => e
      render json: {text: 'Sorry, something went wrong. Please check the logs for details.'}, status: 404
    end

  end

end