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

end