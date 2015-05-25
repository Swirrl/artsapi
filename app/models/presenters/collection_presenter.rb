require 'memoist'
module Presenters

  class CollectionPresenter

    extend Memoist

    attr_accessor :contains_type, :collection

    def initialize(type=nil, opts={})
      self.contains_type = type.to_sym
      other_collection = opts.fetch(:collection, nil)

      case type.to_sym
      when :organisation
        self.collection = Organisation.all.resources
      when :person
        self.collection = Person.all.resources
      when nil
        self.collection = other_collection
      end
    end

    # attempt to sort by size, otherwise just return collection
    # this is important in case they do this before processing their data
    def sorted
      begin
        sorted_by_size
      rescue
        self.collection
      end
    end
    memoize :sorted

    def sorted_by_size
      case self.contains_type
      when :organisation
        self.collection.sort { |a, b| b.has_members.count <=> a.has_members.count }
      when :person
        self.collection.sort { |a, b| b.number_of_sent_emails <=> a.number_of_sent_emails }
      end
    end

    def plural_type
      self.contains_type.to_s.pluralize.titleize
    end

    def country_list
      ArtsAPI::COUNTRIES_MAPPING.values
    end
    memoize :country_list

    def sector_list
      resources = SICConcept.all_classes_and_subclasses
      results = []
      to_prepend = []

      # array needs to be [label, value]
      resources.each do |resource|
        uri = resource.uri.to_s

        if SICConcept.sic_extension_uris.include?(uri)
          to_prepend << [resource.label, uri]
        else
          results << [resource.label, uri]
        end
      end

      to_prepend + results
    end
    memoize :sector_list

  end

end