module Concept

  extend ActiveSupport::Concern

  included do
    class_attribute :resource_concept_scheme_uri
    class_attribute :resource_broad_concept_uri
    class_attribute :resource_concept_scheme_label
    field :in_scheme, RDF::SKOS.inScheme, :is_uri => true
    field :label, RDF::RDFS.label
    field :description, 'http://purl.org/dc/terms/description'
    field :sub_class_of, RDF::SKOS.subClassOf, :is_uri => true
    field :broader, RDF::SKOS.broader, :is_uri => true
    field :narrower, RDF::SKOS.narrower, :is_uri => true, :multivalued => true
    rdf_type RDF::SKOS.Concept
  end

end