module RDF
  #SITE = RDF::Vocabulary.new("#{ARTSAPI_VOCAB_ROOT}/def/")
  ARTS = RDF::Vocabulary.new("http://artsapi.com/def/arts/")
  KEYWORDS = RDF::Vocabulary.new("http://artsapi.com/def/arts/keywords/")
  ORG = RDF::Vocabulary.new("http://www.w3.org/ns/org#")
  DCAT = RDF::Vocabulary.new("http://www.w3.org/ns/dcat#")
  VOID = RDF::Vocabulary.new("http://rdfs.org/ns/void#")
  CUBE = RDF::Vocabulary.new("http://purl.org/linked-data/cube#")
  VCARD = RDF::Vocabulary.new("http://www.w3.org/2006/vcard/ns#")
  FOAF = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
  DC_ELEM = RDF::Vocabulary.new("http://purl.org/dc/elements/1.1/")
end