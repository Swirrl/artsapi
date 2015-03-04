class Person

  include Tripod::Resource

  rdf_type 'http://xmlns.com/foaf/0.1/Person'
  graph_uri 'http://artsapi.com/graph/people'

  field :account, RDF::FOAF['account'], is_uri: true
  field :name, RDF::FOAF['name']
  field :given_name, RDF::FOAF['givenName']
  field :family_name, RDF::FOAF['familyName']
  field :knows, RDF::FOAF['knows'], is_uri: true
  field :made, RDF::FOAF['made'], is_uri: true
  field :has_email, RDF::VCARD['hasEmail']
  field :mbox, RDF::FOAF['mbox']
  field :member_of, RDF::ORG['memberOf'], is_uri: true
  field :connection, RDF::ARTS['connection'], is_uri: true
  field :position, RDF::ARTS['position']
  field :department, RDF::ARTS['department']
  field :possible_department, RDF::ARTS['possibleDepartment']

  # we may use these
  # field :subject_area
  # field :functional_area
  # field :contains_keyword

  # on initialize we need to work out connections in order to display them. SPARQL time!

  def all_accounts
  end

  def all_emails
    Email.find_by_sparql("
      SELECT ?uri 
      WHERE { 
        ?uri a <http://artsapi.com/def/arts/Email> . 
        <#{self.uri.to_s}> <http://xmlns.com/foaf/0.1/made> ?uri . 
      }")
  end

  def number_of_sent_emails
    all_emails.count
  end

end