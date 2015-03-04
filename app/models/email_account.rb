class EmailAccount

  include Tripod::Resource

  rdf_type 'http://artsapi.com/def/arts/EmailAccount'
  graph_uri 'http://artsapi.com/graph/email-accounts'

  field :account_name, RDF::FOAF['accountName']
  field :has_email, RDF::VCARD['hasEmail']

end