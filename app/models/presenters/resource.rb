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

    def get_fields_hash
      resource.fields
    end

    def fields
      results = []

      fields_hash = get_fields_hash

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

              if item.to_s.match(/http:\/\/data.artsapi.com\/id.+/) # it is a uri
                Presenters::Resource.create_link_from_uri(item)
              else
                item unless item.nil? || item.blank?
              end

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
        URI(uri.to_s.match(/http:\/\/data\.artsapi\.com\/id.+/)[0]).path
      end

      def create_link_from_uri(uri, opts={})
        text = opts.fetch(:text, nil)
        text = uri if text.nil?
        path = create_path_from_uri(uri)
        "<a href='#{path}'>#{text}</a>"
      end

    end

  end
end