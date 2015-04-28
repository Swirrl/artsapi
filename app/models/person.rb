class Person < ResourceWithPresenter

  include Tripod::Resource
  include Connections
  include TripodOverrides

  rdf_type 'http://xmlns.com/foaf/0.1/Person'
  graph_uri 'http://data.artsapi.com/graph/people'

  attr_accessor :all_connections, :correct_name

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

  field :sent_emails, RDF::ARTS['sentEmails']
  field :incoming_emails, RDF::ARTS['incomingEmails']
  field :mentioned_keywords, RDF::ARTS['mentionedKeyword'], is_uri: true, multivalued: true

  def human_name
    name_array = self.name
    name_array.delete("")

    if self.correct_name.nil? && name_array.length > 1
      results = {}
      all_split = name_array.map { |n| n.downcase.split(' ') }.flatten

      all_split.each do |word|

        if results.has_key?(word)
          results[word] = results[word] += 1
        else
          results[word] = 1
        end

      end

      top_two = results.sort_by { |name, occurrences| occurrences }[-2..-1]
      self.correct_name = sanitize_name("#{top_two.last[0]} #{top_two.first[0]}").titleize
    else
      match = sanitized_default_name.match(/^[A-Z][a-z]+\b +\b[A-Z][a-z]+$/)
      self.correct_name = match[0] if !match.nil?
    end

    self.correct_name || self.sanitized_default_name
  end

  def sanitized_default_name
    (self.name.first.nil? || self.name.first.blank?) ? 'No Name Available' : sanitize_name(self.name.first).titleize
  end

  def sanitize_name(name)
    name.strip
      .gsub(/'/, '')
      .gsub(/\'/, '')
      .gsub(/,/, '')
      .gsub(/\,/, '')
      .gsub(/"/, '')
      .gsub(/\"/, '')
      .gsub(/\(/, '')
      .gsub(/\)/, '')
      .gsub(/\n/, '')
      .gsub(/\\n/, '')
  end

  def all_emails
    User.current_user.within {
      Email.find_by_sparql("
        SELECT DISTINCT ?uri 
        WHERE { 
          ?uri a <http://data.artsapi.com/def/arts/Email> .
          <#{self.uri.to_s}> <http://xmlns.com/foaf/0.1/made> ?uri .
        }")
    }
  end

  def number_of_sent_emails
    if self.sent_emails.nil?
      query = Tripod::SparqlQuery.new("
        #{Person.query_prefixes}
        SELECT DISTINCT ?uri 
        WHERE {
          GRAPH <http://data.artsapi.com/graph/emails> {
            ?uri arts:emailSender <#{self.uri.to_s}> .
          } 
        }
        ")

      number_of_emails = User.current_user.within {
        Tripod::SparqlClient::Query.select(query.as_count_query_str)[0]["tripod_count_var"]["value"].to_i
      }

      self.sent_emails = number_of_emails
      self.save

      number_of_emails
    else
      self.sent_emails
    end
  end

  def number_of_incoming_emails
    if self.incoming_emails.nil?
      query = Tripod::SparqlQuery.new("
        #{Person.query_prefixes}
        SELECT DISTINCT ?uri 
        WHERE { 
          GRAPH <http://data.artsapi.com/graph/emails> {
            ?uri arts:emailRecipient <#{self.uri.to_s}> .
          } 
        }
        ")

      number_of_emails = User.current_user.within {
        Tripod::SparqlClient::Query.select(query.as_count_query_str)[0]["tripod_count_var"]["value"].to_i
      }

      self.incoming_emails = number_of_emails
      self.save

      number_of_emails
    else
      self.incoming_emails
    end
  end

  def all_keywords_from_emails
    kw_hash = {}

    self.mentioned_keywords.each do |keyword|
      kw = keyword.to_s

      query = Tripod::SparqlQuery.new("
        #{Person.query_prefixes}
        SELECT ?email
        WHERE {
          GRAPH <http://data.artsapi.com/graph/emails> {
            ?email arts:emailSender <#{self.uri.to_s}> .
            ?email arts:containsKeyword <#{kw}> .
          }
        }
      ")

      mentions = User.current_user.within {
        Tripod::SparqlClient::Query.select(query.as_count_query_str)[0]["tripod_count_var"]["value"].to_i
      }

      label = Keyword.label_from_uri(kw)
      kw_hash[kw] = [label, mentions]
    end

    kw_hash
  end

  def sorted_keywords
    sorted = []
    ak = all_keywords_from_emails
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
      "#{ArtsAPI::HOST}/id/people/#{email_string.strip.downcase.gsub(/\./, '-').gsub(/@/, '-')}"
    end

    def get_rdf_uri_from_email(email_string)
      RDF::URI(self.get_uri_from_email(email_string))
    end

    def query_prefixes
      "PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX arts: <http://data.artsapi.com/def/arts/>
      PREFIX org: <http://www.w3.org/ns/org#>"
    end

    def total_count

      # get unhydrated uris
      all_people_query = "
        SELECT DISTINCT ?uri
        WHERE {
          GRAPH <http://data.artsapi.com/graph/people> {
            ?uri a <http://xmlns.com/foaf/0.1/Person> .
          }
        }"

      User.current_user.within { Tripod::SparqlClient::Query.select(all_people_query).count }
    end

    # write connections for arrays or single strings
    # we check and avoid writing self <-> self as a connection
    def write_connections_on(person, conns)
      if conns.is_a? Array
        conns.delete(person.uri.to_s)
        person.connections = conns
      else
        person.connections = person.connections + [conns] unless person.uri.to_s == conns
      end

      begin
        person.save!
      rescue
        false
      end
    end

  end

end