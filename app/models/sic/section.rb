module SIC

  class Section

    include Tripod::Resource
    include SICConcept

    rdf_type 'http://swirrl.com/def/sic/Section'
    graph_uri 'http://data.artsapi.com/graph/sic'

  end

end