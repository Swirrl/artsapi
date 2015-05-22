module SIC

  class Class

    include Tripod::Resource
    include SICConcept

    rdf_type 'http://swirrl.com/def/sic/Class'
    graph_uri 'http://data.artsapi.com/graph/sic'

  end

end