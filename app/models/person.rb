class Person

  include Tripod::Resource

  rdf_type 'http://xmlns.com/foaf/0.1/Person'
  graph_uri 'http://artsapi.com/graph/people'

  attr_accessor :all_connections

  field :account, RDF::FOAF['account'], is_uri: true, multivalued: true
  field :name, RDF::FOAF['name'], multivalued: true
  field :given_name, RDF::FOAF['givenName']
  field :family_name, RDF::FOAF['familyName']
  field :knows, RDF::FOAF['knows'], is_uri: true
  field :made, RDF::FOAF['made'], is_uri: true, multivalued: true
  field :has_email, RDF::VCARD['hasEmail']
  field :mbox, RDF::FOAF['mbox']
  field :member_of, RDF::ORG['memberOf'], is_uri: true
  field :connections, RDF::ARTS['connection'], is_uri: true, multivalued: true
  field :position, RDF::ARTS['position']
  field :department, RDF::ARTS['department']
  field :possible_department, RDF::ARTS['possibleDepartment']

  #linked_to :email, :made

  # we may use these
  # field :subject_area
  # field :functional_area
  # field :contains_keyword

  # on initialize we need to work out connections in order to display them. SPARQL time!

  def human_name
    correct_name = nil

    self.name.each do |n| 
      match = n.strip.match(/^[A-Z][a-z]+\b \b[A-Z][a-z]+$/)
      correct_name = match[0] if !match.nil?
    end

    correct_name ||= self.name.first
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

  def get_recipients_of_emails
    Tripod::SparqlClient::Query.select("
      #{Person.query_prefixes}

      SELECT DISTINCT ?person
      WHERE {
        ?person a foaf:Person .
        ?email a arts:Email .

        GRAPH <http://artsapi.com/graph/emails> {
          ?email arts:emailRecipient ?person
        }

        VALUES ?email { <#{self.all_emails.map(&:uri).join("> <")}> }
      }
    ").map { |r| r["person"]["value"] }
  end

  def get_incoming_mail_senders
    Tripod::SparqlClient::Query.select("
      #{Person.query_prefixes}

      SELECT DISTINCT ?person
      WHERE {
        ?person a foaf:Person .
        ?email a arts:Email .

        GRAPH <http://artsapi.com/graph/emails> {
          ?email arts:emailRecipient <#{self.uri}>.
          ?email arts:emailSender ?person .
        }
      }
      ").map { |r| r["person"]["value"] }
  end

  # memoizes all connections to self.all_collections to avoid db calls later
  def get_connections
    if self.connections.empty?
      calculate_connections
      write_connections
    end

    self.all_connections = self.connections
    self.all_connections
  end

  def calculate_connections
    connection_set = []
    recipients = self.get_recipients_of_emails

    filtered = Tripod::SparqlClient::Query.select("
      #{Person.query_prefixes}

      SELECT DISTINCT ?person

      WHERE {
        ?person a foaf:Person .
        ?email a arts:Email .

        GRAPH <http://artsapi.com/graph/emails> {
          ?email arts:emailRecipient <#{self.uri}>.
          ?email arts:emailSender ?person .
        }
        VALUES ?person { <#{recipients.join("> <")}> }
      }
      ").map { |r| r["person"]["value"] }

    self.all_connections = filtered
  end

  # write connections between foaf:People and
  # write connections between org:Organizations
  def write_connections

    begin
      self.connections << self.all_connections # write the connections on this Person
      self.save!
    rescue

    end

    begin
      self.all_connections.each do |conn|
        other_person.connections << self.uri # write on the other Person
        other_person.save!
      end
    rescue

    end

    Organisation.write_link(self.member_of, other_person.member_of)
  end

  def all_keywords
    kw_hash = {}

    all_emails.each do |e| 
      e.contains_keywords.each do |kw|

        if kw_hash.has_key?(kw.to_s)
          kw_hash[(kw.to_s)][1] = kw_hash[(kw.to_s)][1] += 1
        else
          label = Keyword.find(kw.to_s).label rescue Keyword.label_from_uri(kw)
          kw_hash[(kw.to_s)] = [label, 1]
        end

      end
    end

    kw_hash
  end

  def sorted_keywords
    sorted = []
    ak = all_keywords
    ak.sort { |a, b| ak[b[0]][1] <=> ak[a[0]][1] }.each { |h| sorted << [ak[h[0]][0], ak[h[0]][1]] }
    sorted
  end

  def keywords_csv
  end

  # for use in rake tasks etc
  # works out a possible department and writes a triple
  def generate_and_write_possible_department
  end

  # for debug and partner feedback; not for production use!
  def print_sorted_keywords
    puts "#{self.name.titleize}: #{self.uri}\n\n"
    sorted_keywords.each { |a| puts "'#{a[0]}' mentions: #{a[1]}"}
  end

  def get_colleagues
    Organisation.find(self.member_of).has_members
  end

  class << self

    def get_uri_from_email(email_string)
      "#{ArtsAPI::HOST}/id/people/#{email_string.downcase.gsub(/\./, '-').gsub(/@/, '-')}"
    end

    def rdf_uri_from_email(email_string)
      RDF::URI(self.get_uri_from_email(email_string))
    end

    def query_prefixes
      "PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX arts: <http://artsapi.com/def/arts/>"
    end

  end

end