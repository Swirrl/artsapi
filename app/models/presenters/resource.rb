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
        # useful anchor tag creator
        if object.is_a?(Array)
          if !object.empty?
            object = object.map { |item|

              Presenters::Resource.create_link_from_uri(item) if item.to_s.match(/http:\/\/artsapi.com\/id.+/) # it is a uri

            }.join(", ")
          end
        end

        results << [description, predicate, object]

      end

      results
    end

    def person?
      !!(resource.class.name == 'Person')
    end

    def organisation?
      !!(resource.class.name == 'Organisation')
    end

    class << self

      def create_path_from_uri(uri)
        URI(uri.to_s.match(/http:\/\/artsapi.com\/id.+/)[0]).path
      end

      def create_link_from_uri(uri)
        path = create_path_from_uri(uri)
        "<a href='#{path}'>#{uri}</a>"
      end

    end

  end
end