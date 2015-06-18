module Presenters
  class OrganisationPresenter < Presenters::Resource

    extend Memoist

    def linked_organisations
      resource.linked_to
    end

    def linked_organisations_count
      linked_organisations.size
    end

    def linked_organisations_text
       linked_organisations_count == 1 ? "#{linked_organisations_count} Linked Organisation" : "#{linked_organisations_count} Linked Organisations"
    end

    def linked_organisations_data
      linked_organisations.map { |lo| 
        o = Organisation.find(lo)
        [lo.to_s, 
          o.has_members.size, 
          o.linked_to.size]
      }.sort { |a,b| b[1] <=> a[1] }
    end

    def members
      resource.has_members
    end

    def number_of_members
      members.size
    end

    def network_density
      SNA.network_density
    end

    def members_data
      members.map { |m|
        p = Person.find(m)
        [Presenters::Resource.create_path_from_uri(m.to_s), 
          p.human_name,
          p.connections.count]
      }.sort { |a,b| b[2] <=> a[2] }
    end

    def get_fields_hash
      if Rails.env.test?
        super
      else
        fields_hash = resource.fields.dup
        fields_hash.delete(:graph_visualisation)
        fields_hash.delete(:has_members)
        fields_hash.delete(:linked_to)
        fields_hash
      end
    end

    def common_subject_areas
      common_areas = resource.common_subject_areas

      if common_areas.blank?
        resource.get_common_subject_areas!.map { |uri| KeywordCategory.find(uri) }
      else
        common_areas.map { |uri| KeywordCategory.find(uri) }
      end
    end

    def common_subject_areas_sentence
      common_subject_areas.map(&:label).to_sentence rescue "Unavailable"
    end

    def common_keywords
      common_keywords = resource.common_keywords

      if common_keywords.blank?
        resource.get_common_keywords!.map { |uri| Keyword.find(uri) }
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