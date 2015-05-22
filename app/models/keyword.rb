class Keyword

  include Tripod::Resource
  include TripodOverrides

  # @prefix keywordresource: <http://data.artsapi.com/id/keywords/keyword/> .

  rdf_type 'http://data.artsapi.com/def/arts/keywords/Keyword'
  graph_uri 'http://data.artsapi.com/graph/keywords'

  field :label, RDF::RDFS.label
  field :in_sub_category, 'http://data.artsapi.com/def/arts/keywords/inSubCategory', is_uri: true

  # returns a RDF::URI
  def get_category
    sub_category = KeywordSubCategory.find(self.in_sub_category)
    sub_category.in_category
  end

  class << self

    def label_from_uri(uri)
      uri.to_s.match(/\/[A-z]+$/)[0][1..-1].titleize
    end

    def uri_from_label(label)
      "#{ArtsAPI::HOST}/id/keywords/keyword/#{label.downcase}"
    end

    def hydrate_from_label(label)
      Keyword.find(uri_from_label(label))
    end

  end

end