class EmailAccount < ResourceWithPresenter

  include Tripod::Resource

  rdf_type 'http://data.artsapi.com/def/arts/EmailAccount'
  graph_uri 'http://data.artsapi.com/graph/email-accounts'

  field :account_name, RDF::FOAF['accountName']
  field :has_email, RDF::VCARD['hasEmail']

  # override to use correct db
  def find(uri, opts={})
    User.current_user.within do
      super(uri, opts)
    end
  end

end