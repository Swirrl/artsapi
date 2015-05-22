module SIC

  class Division

    include Tripod::Resource
    include SICConcept

    rdf_type 'http://swirrl.com/def/sic/Division'
    graph_uri 'http://data.artsapi.com/graph/sic'

  end

end