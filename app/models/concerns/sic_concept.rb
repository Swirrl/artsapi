module SICConcept

  extend ActiveSupport::Concern

  included do
    field :label, RDF::RDFS.label
    field :code, "http://swirrl.com/def/sic/code"
  end

  def self.all_classes_and_subclasses
    results = []

    SIC::Class.all.resources.each { |r| results << r }
    SIC::SubClass.all.resources.each { |r| results << r }

    results
  end

  def self.find_class_or_subclass(uri)
    begin
      SIC::SubClass.find(uri)
    rescue
      SIC::Class.find(uri)
    end
  end

  def self.uri_from_sic_code(sic_code)
  end

  def self.sic_extension_uris
    ["http://swirrl.com/id/sic/90031", "http://swirrl.com/id/sic/90011", "http://swirrl.com/id/sic/90032", "http://swirrl.com/id/sic/90012", "http://swirrl.com/id/sic/90013", "http://swirrl.com/id/sic/90033"]
  end

end