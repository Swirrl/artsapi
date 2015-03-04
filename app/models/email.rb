class Email

  include Tripod::Resource

  rdf_type 'http://artsapi.com/def/arts/Email'
  graph_uri 'http://artsapi.com/graph/emails'

  field :sender, RDF::ARTS['emailSender'], is_uri: true
  field :recipient, RDF::ARTS['emailRecipient'], is_uri: true
  field :cc_recipient, RDF::ARTS['ccRecipient'], is_uri: true
  field :has_domain, RDF::ARTS['hasDomain'], is_uri: true
  field :contains_keyword, RDF::ARTS['containsKeyword'], is_uri:true
  field :sent_at, RDF::ARTS['sentAt'], :datatype => RDF::XSD.datetime

  def all_keywords
    Concepts::Keyword.find_by_sparql("
      SELECT ?uri 
      WHERE { 
        ?uri a <http://artsapi.com/def/arts/keywords/Keyword> . 
        <#{self.uri.to_s}> <http://artsapi.com/def/arts/containsKeyword> ?uri . 
      }")
  end

end