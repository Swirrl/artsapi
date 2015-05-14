class LabelsController < ApplicationController

  before_filter :authenticate_user!

  def find
    uri = params[:uri]

    respond_to do |format|
      format.json {
        begin
          label = find_resource_label_by_uri(uri)
          render json: {text: label}
        rescue
          render json: {text: 'Label not found'}, status: 404
        end
      }
    end
    
  end

  def replace
    resource_uri = params[:uri]
    new_label = params[:label]

    begin
      resource = Dispatcher.find_and_cast(resource_uri)

      resource.label = new_label
      resource.save

      render text: new_label, status: 200
    rescue
      render text: 'New label saving failed', status: 500
    end

  end

  private

  # try and return label
  # or try and return name
  def find_resource_label_by_uri(uri)
    User.current_user.within {
      Tripod::SparqlClient::Query.select("
        SELECT DISTINCT ?label
        WHERE {
          { <#{uri}> <http://www.w3.org/2000/01/rdf-schema#label> ?label }
          UNION
          { <#{uri}> <http://xmlns.com/foaf/0.1/name> ?label}
        }
        LIMIT 1
        ")[0]["label"]["value"]
    }
  end

end