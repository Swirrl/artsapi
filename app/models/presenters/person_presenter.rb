module Presenters
  class PersonPresenter < Presenters::Resource

    extend Memoist

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

    def resource_position
      resource.position || "Unavailable"
    end

    def functional_areas
      resource.functional_area.map { |fa| KeywordSubCategory.find(fa) } || "Not known"
    end

    def functional_areas_sentence
      functional_areas.map(&:label).to_sentence
    end

    def subject_area
      resource_subject_area_uri = resource.subject_area.first
      (resource_subject_area_uri.nil?) ? KeywordCategory.find(resource.get_subject_area!.first) : KeywordCategory.find(resource_subject_area_uri)
    end

    def subject_areas
      resource_subject_area_uris = resource.subject_area

      if resource_subject_area_uris.blank?
        resource.get_subject_area!.map { |uri| KeywordCategory.find(uri) }
      else
        resource_subject_area_uris.map { |uri| KeywordCategory.find(uri) }
      end
    end

    def subject_area_label
      subject_area.label rescue "Unavailable"
    end

    def subject_areas_labels
      subject_areas.map(&:label)
    end

    def subject_areas_sentence
      subject_areas_labels.to_sentence rescue "Unavailable"
    end

    def common_subject_areas
      parent_org = Organisation.find(resource.member_of)
      common_areas = parent_org.common_subject_areas

      if common_areas.blank?
        parent_org.get_common_subject_areas!.map { |uri| KeywordCategory.find(uri) }
      else
        common_areas.map { |uri| KeywordCategory.find(uri) }
      end
    end

    def common_subject_areas_sentence
      common_subject_areas.map(&:label).to_sentence rescue "Unavailable"
    end

    def common_keywords
      parent_org = Organisation.find(resource.member_of)
      common_keywords = parent_org.common_keywords

      if common_keywords.blank?
        parent_org.get_common_keywords!.map { |uri| Keyword.find(uri) }
      else
        common_keywords.map { |uri| Keyword.find(uri) }
      end
    end

    def common_keywords_labels
      common_keywords.map(&:label) rescue "Unavailable"
    end

    def common_keywords_sentence
      common_keywords_labels.to_sentence rescue "Unavailable"
    end

  end
end