class Keyword

  include Tripod::Resource

  # @prefix keywordresource: <http://artsapi.com/id/keywords/keyword/> .

  rdf_type 'http://artsapi.com/def/arts/keywords/Keyword'
  graph_uri 'http://artsapi.com/def/arts/keywords/keywords'

  field :label, RDF::RDFS.label
  field :in_sub_category, 'http://artsapi.com/def/arts/keywords/inSubCategory', is_uri: true

  class << self

    def label_from_uri(uri)
      uri.to_s.match(/\/[A-z]+$/)[0][1..-1].titleize
    end

    def uri_from_label(label)
      "#{ArtsAPI::HOST}/id/keywords/keyword/#{label.downcase}"
    end

  end

end