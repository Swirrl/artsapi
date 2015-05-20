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
        self.collection.sort { |a, b| b.sent_emails.count <=> a.sent_emails.count }
      end
    end

    def plural_type
      self.contains_type.to_s.pluralize.titleize
    end

    def all_sic_categories

    end

    def country_list
      ArtsAPI::COUNTRIES_MAPPING.values
    end
    memoize :country_list

  end

end