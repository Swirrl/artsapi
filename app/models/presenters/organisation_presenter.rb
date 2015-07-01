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
          o.linked_to.size,
          o.label]
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
          SNA.degree_centrality_for_person!(m.to_s).round(5),
          p.connections.count]
      }.sort { |a,b| b[2] <=> a[2] }
    end

    def country_list
      ArtsAPI::COUNTRIES_MAPPING.values.uniq
    end
    memoize :country_list

    def city_list
      Organisation.all_unique_city_values
    end
    memoize :city_list

    def sector_list
      SICConcept.all_classes_and_subclasses
    end
    memoize :sector_list

    def country_table
      output = []

      countries_with_no_orgs = 0

      country_list.each do |country|
        orgs_in_country = Organisation.all_organisations_in_country(country)

        if orgs_in_country.count > 0
          row = [country]
          row << orgs_in_country.count
          row << orgs_in_country # return uris and labels in case needed later
          output << row
        else
          # do not add row
          countries_with_no_orgs += 1
        end

      end

      output.sort! { |a, b| b[1] <=> a[1] }
      # output << ["Countries with no known Organisations", countries_with_no_orgs, []]

      output
    end

    def city_table
      output = []

      city_list.each do |city|
        row = [city]

        orgs_in_city = Organisation.all_organisations_in_city(city)
        row << orgs_in_city.count
        row << orgs_in_city # return uris and labels in case needed later
        output << row
      end

      output.sort! { |a, b| b[1] <=> a[1] }

      output
    end

    # slightly different to the above; each row is 
    # [uri, label, number]
    def sector_table
      output = []

      sector_list.each do |sector|
        sector_uri = sector.uri.to_s

        orgs_in_sector = Organisation.all_organisations_in_sector(sector_uri)
        if orgs_in_sector.count > 0
          row = [sector_uri, sector.label]
          row << orgs_in_sector.count
          output << row
        end
      end

      output.sort! { |a, b| b[2] <=> a[2] }

      output
    end

    def get_fields_hash
      fields_hash = resource.fields.dup
      fields_hash.delete(:graph_visualisation)
      fields_hash.delete(:has_members)
      fields_hash.delete(:linked_to)
      fields_hash
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