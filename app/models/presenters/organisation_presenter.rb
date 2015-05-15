module Presenters
  class OrganisationPresenter < Presenters::Resource

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
      }.sort { |a,b| b[2] <=> a[2] }
    end

    def members
      resource.has_members
    end

    def number_of_members
      members.size
    end

    def members_data
      members.map { |m|
        p = Person.find(m)
        [Presenters::Resource.create_path_from_uri(m.to_s), 
          p.human_name]
      }
    end

    def get_fields_hash
      if Rails.env.test?
        super
      else
        fields_hash = resource.fields
        fields_hash.delete(:graph_visualisation)
        fields_hash.delete(:has_members)
        fields_hash.delete(:linked_to)
        fields_hash
      end
    end

  end
end