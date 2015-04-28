class Keyword

  include Tripod::Resource

  # @prefix keywordresource: <http://data.artsapi.com/id/keywords/keyword/> .

  rdf_type 'http://data.artsapi.com/def/arts/keywords/Keyword'
  graph_uri 'http://data.artsapi.com/graph/keywords'

  field :label, RDF::RDFS.label
  field :in_sub_category, 'http://data.artsapi.com/def/arts/keywords/inSubCategory', is_uri: true

  # override to use correct db
  def find(uri, opts={})
    User.current_user.within do
      super(uri, opts)
    end
  end

  class << self

    def label_from_uri(uri)
      uri.to_s.match(/\/[A-z]+$/)[0][1..-1].titleize
    end

    def uri_from_label(label)
      "#{ArtsAPI::HOST}/id/keywords/keyword/#{label.downcase}"
    end

  end

end