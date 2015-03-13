module Presenters
  class Resource

    attr_accessor :resource

    def initialize(res)
      self.resource = res
    end

    def resource_uri
      resource.uri
    end

    def title
      if person?
        resource.human_name
      else
        resource.label rescue 'Resource'
      end

    end

    def fields
      results = []

      fields_hash = resource.fields

      fields_hash.each do |k,v|
        description = v.name.to_s.gsub(/-/,' ').titleize
        predicate = v.predicate.to_s

        if person? && v.name == :made
            object = ["#{resource.number_of_sent_emails} Emails"]
        else
          object = resource.send(v.name)
        end

        # annoying array sanitization
        if object.is_a?(Array)
          object = !object.empty? ? object.join(", ") : ''
        end

        results << [description, predicate, object]

      end

      results
    end

    # if there are less than 10 connections, they've probably been created by other resources
    # that have written to this one, the list is likely to be much larger
    def connections
      resource.connections.length < 10 ? generate_and_get_connections : "#{resource.connections.count} Connections"
    end

    def generate_and_get_connections
      resource.generate_connections_async
      "The data is currently loading - please refresh the page in a couple of minutes."
    end

    def person?
      !!(resource.class.name == 'Person')
    end

  end
end