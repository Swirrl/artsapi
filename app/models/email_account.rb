class EmailAccount < ResourceWithPresenter

  include Tripod::Resource
  extend TripodOverrides

  rdf_type 'http://data.artsapi.com/def/arts/EmailAccount'
  graph_uri 'http://data.artsapi.com/graph/email-accounts'

  field :account_name, RDF::FOAF['accountName']
  field :has_email, RDF::VCARD['hasEmail']

end