module Presenters
  class PersonPresenter < Presenters::Resource

    # if there are less than 10 connections, they've probably been created by other resources
    # that have written to this one, the list is likely to be much larger
    def connections
      if resource.connections.empty?
        generate_and_get_connections
      elsif connections_length < 15
        nil
      else
        "#{resource.connections.count} Connections"
      end
    end

    def get_fields_hash
      if Rails.env.test?
        super
      else
        fields_hash = resource.fields
        fields_hash.delete(:graph_visualisation)
        fields_hash
      end
    end

    def connections_length
      resource.connections.length
    end

    def generate_and_get_connections
      resource.generate_connections_async
      "Connections are being calculated for this Person. Please refresh in a few minutes."
    end

    def keywords
      resource.sorted_keywords
    end

    def weighted_connections
      resource.sorted_email_density
    end

    def functional_areas
      resource.functional_area.map { |fa| KeywordSubCategory.find(fa) } || "Not known"
    end

    def subject_area
      resource_subject_area_uri = resource.subject_area
      (resource_subject_area_uri.nil?) ? resource.get_subject_area! : KeywordCategory.find(resource_subject_area_uri)
    end

    def subject_area_label
      subject_area.label rescue "Unavailable"
    end

  end
end