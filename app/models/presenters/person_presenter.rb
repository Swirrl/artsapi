module Presenters
  class PersonPresenter < Presenters::Resource

    # if there are less than 10 connections, they've probably been created by other resources
    # that have written to this one, the list is likely to be much larger
    def connections
      resource.connections.length < 10 ? generate_and_get_connections : "#{resource.connections.count} Connections"
    end

    def generate_and_get_connections
      resource.generate_connections_async
      "The data is currently loading - please refresh the page in a couple of minutes."
    end

    def keywords
      resource.sorted_keywords
    end

    def weighted_connections
      resource.sorted_email_density
    end

  end
end