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

    # this is far and away the slowest method called during page load
    # unfortunately to sort for the UI, we need to know connections
    def members_data
      members.map { |m|
        connections = Person.get_connections_count_for(m.to_s)
        connections = Person.connections_count_for(m.to_s) if connections == 0

        [Presenters::Resource.create_path_from_uri(m.to_s), 
          m.to_s,
          SNA.degree_centrality_for_person!(m.to_s).round(5),
          connections]
      }.sort { |a,b| b[3] <=> a[3] }
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

    def linked_orgs_uri_strings
      resource.linked_to.map(&:to_s)
    end
    memoize :linked_orgs_uri_strings

    # expects a multidimensional array
    # with structure [uri, label]; uri is a string
    def eliminate_unlinked_orgs(orgs)
      orgs.map { |org_array| org_array if linked_orgs_uri_strings.include?(org_array[0]) }.compact
    end

    def country_table
      output = []

      countries_with_no_orgs = 0

      country_list.each do |country|
        orgs_in_country = Organisation.all_organisations_in_country(country)
        orgs_in_country = eliminate_unlinked_orgs(orgs_in_country)

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
        orgs_in_city = Organisation.all_organisations_in_city(city)
        orgs_in_city = eliminate_unlinked_orgs(orgs_in_city)

        if orgs_in_city.count > 0
          row = [city]
          row << orgs_in_city.count
          row << orgs_in_city # return uris and labels in case needed later
          output << row
        end
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
        orgs_in_sector = eliminate_unlinked_orgs(orgs_in_sector)

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