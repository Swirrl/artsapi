require 'memoist'
module Presenters

  class CollectionPresenter

    extend Memoist

    attr_accessor :contains_type, :collection

    def initialize(type=nil, opts={})
      type = type.to_sym if !type.nil?
      self.contains_type = type
      other_collection = opts.fetch(:collection, nil)

      case type
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

      # this may be the first time they have logged in
      # in which case SIC will not be loaded yet
      if resources.empty?
        User.bootstrap_sic_for_current_user! 
        resources = SICConcept.all_classes_and_subclasses
      end

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

    def sector_list_labels
      sector_list.map { |i| i[0] }
    end
    memoize :sector_list_labels

    def sic_sector_label_for(org)
      return nil if org.sector.nil?
      uri = org.sector
      SICConcept.find_class_or_subclass(uri).label
    end

  end

end