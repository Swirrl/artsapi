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
      case resource.class.name

      when 'Person'
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
        object = resource.send(v.name)

        results << [description, predicate, object]

      end

      results
    end

  end
end