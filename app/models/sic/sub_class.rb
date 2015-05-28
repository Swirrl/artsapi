module SIC

  class SubClass

    include Tripod::Resource
    extend TripodOverrides
    include SICConcept

    rdf_type 'http://swirrl.com/def/sic/SubClass'
    graph_uri 'http://data.artsapi.com/graph/sic'

  end

end