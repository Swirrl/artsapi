class Concepts::Keyword

  include Tripod::Resource
  include Concept

  # @prefix keywordresource: <http://artsapi.com/id/keywords/keyword/> .

  graph_uri 'http://artsapi.com/def/arts/keywords/keywords'


  class << self

    def label_from_uri(uri)
      uri.to_s.match(/\/[A-z]+$/)[0][1..-1].titleize
    end

  end

end