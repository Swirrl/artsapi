class Person

  include Tripod::Resource

  rdf_type 'http://xmlns.com/foaf/0.1/Person'
  graph_uri 'http://artsapi.com/graph/people'

  field :account, RDF::FOAF['account'], is_uri: true, multivalued: true
  field :name, RDF::FOAF['name']
  field :given_name, RDF::FOAF['givenName']
  field :family_name, RDF::FOAF['familyName']
  field :knows, RDF::FOAF['knows'], is_uri: true
  field :made, RDF::FOAF['made'], is_uri: true, multivalued: true
  field :has_email, RDF::VCARD['hasEmail']
  field :mbox, RDF::FOAF['mbox']
  field :member_of, RDF::ORG['memberOf'], is_uri: true
  field :connection, RDF::ARTS['connection'], is_uri: true
  field :position, RDF::ARTS['position']
  field :department, RDF::ARTS['department']
  field :possible_department, RDF::ARTS['possibleDepartment']

  #linked_to :email, :made

  # we may use these
  # field :subject_area
  # field :functional_area
  # field :contains_keyword

  # on initialize we need to work out connections in order to display them. SPARQL time!

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

  def all_keywords
    kw_hash = {}

    all_emails.each do |e| 
      e.contains_keywords.each do |kw|

        if kw_hash.has_key?(kw.to_s)
          kw_hash[(kw.to_s)][1] = kw_hash[(kw.to_s)][1] += 1
        else
          label = Concepts::Keyword.find(kw.to_s).label rescue Concepts::Keyword.label_from_uri(kw)
          kw_hash[(kw.to_s)] = [label, 1]
        end

      end
    end

    kw_hash
  end

  class << self

    def get_uri_from_email(email_string)
      "#{ArtsAPI::HOST}/id/people/#{email_string.downcase.gsub(/\./, '-').gsub(/@/, '-')}"
    end

    def rdf_uri_from_email(email_string)
      RDF::URI(self.get_uri_from_email(email_string))
    end

  end

end