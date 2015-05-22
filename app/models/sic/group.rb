module SIC

  class Group

    include Tripod::Resource
    include SICConcept

    rdf_type 'http://swirrl.com/def/sic/Group'
    graph_uri 'http://data.artsapi.com/graph/sic'

  end

end