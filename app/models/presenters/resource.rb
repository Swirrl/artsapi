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

              if item.to_s.match(/http:\/\/artsapi.com\/id.+/) # it is a uri
                old = item
                uri = URI(item.to_s.match(/http:\/\/artsapi.com\/id.+/)[0]).path
                item = "<a href='#{uri}'>#{item}</a>"
              end

              item

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

  end
end