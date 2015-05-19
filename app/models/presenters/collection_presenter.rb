module Presenters

  class CollectionPresenter

    attr_accessor :contains_type, :collection

    def initialize(type=nil, opts={})
      self.contains_type = type
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

    def sorted_by_size
      case self.contains_type
      when :organisation
        self.collection.sort { |a, b| b.has_members.count <=> a.has_members.count }
      when :person
        self.collection.sort { |a, b| b.sent_emails.count <=> a.sent_emails.count }
      end
    end

  end

end