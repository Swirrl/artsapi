class ConnectionsController < ApplicationController

  def find
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