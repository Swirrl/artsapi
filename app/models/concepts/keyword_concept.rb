module Concepts
class KeywordConcept

  include Tripod::Resource
  include Concept

  graph_uri 'http://data.artsapi.com/graph/keywords'

  class << self

    def label_from_uri(uri)
      uri.to_s.match(/\/[A-z]+$/)[0][1..-1].titleize
    end

    def uri_from_label(label)
      "#{ArtsAPI::HOST}/id/keywords/keyword/#{label.downcase}"
    end

  end

end
end