require 'memoist'
class Person < ResourceWithPresenter

  include Tripod::Resource
  extend TripodOverrides
  include Connections
  include PersonKeywordMethods
  extend Memoist

  rdf_type 'http://xmlns.com/foaf/0.1/Person'
  graph_uri 'http://data.artsapi.com/graph/people'

  attr_accessor :all_connections, :correct_name

  field :label, RDF::RDFS.label
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

  # ----- These are the department/role heuristic measures -----
  #       subject_area points to KeywordCategories
  #       functional_area points to KeywordSubCategories
  #       mentioned_keywords points to Keywords
  field :subject_area, RDF::ARTS['subjectArea'], is_uri: true, multivalued: true
  field :functional_area, RDF::ARTS['functionalArea'], is_uri: true, multivalued: true
  field :mentioned_keywords, RDF::ARTS['mentionedKeyword'], is_uri: true, multivalued: true

  # these are essentially things to help performance
  field :sent_emails, RDF::ARTS['sentEmails']
  field :incoming_emails, RDF::ARTS['incomingEmails']
  field :graph_visualisation, RDF::ARTS['visualisation']

  # for SNA
  field :degree_centrality, RDF::ARTS['degreeCentrality']

  def get_visualisation_graph
    if !self.graph_visualisation.nil?
      set_visualisation_graph_async
      JSON.parse(sanitize_json(self.graph_visualisation))
    else
      graph_json = D3::ConnectionsGraph.new(self).formatted_hash
      set_visualisation_graph(graph_json)
      graph_json
    end
  end

  def set_visualisation_graph(hash)
    self.graph_visualisation = hash.to_json
    self.save
  end

  def set_visualisation_graph_async
    current_user_id = User.current_user.id.to_s
    job_id = ::PeopleWorker.perform_in(10.seconds, self.uri.to_s, current_user_id)

    User.add_job_for_current_user(job_id)

    job_id
  end

  def sanitize_json(string)
    string.strip
      .gsub(/\\r/, '')
      .gsub(/\r/, '')
      .gsub(/\n/, '')
      .gsub(/\\n/, '')
      .gsub(/\\/, '')
      .gsub(/\\xC3\\xB5/, '')
  end

  def memoized_connections
    self.connections
  end
  # memoize :memoized_connections

  def human_name
    # label can only be set via the UI so it should always take precedence
    return self.label if !self.label.nil?

    name_array = self.name
    name_array.delete("")

    begin
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
        self.correct_name = sanitize_string("#{top_two.last[0]} #{top_two.first[0]}").titleize
      else
        match = sanitized_default_name.match(/^[A-Z][a-z]+\b +\b[A-Z][a-z]+$/)
        self.correct_name = match[0] if !match.nil?
      end

      self.correct_name || self.sanitized_default_name
    rescue
      self.sanitized_default_name
    end
  end

  def sanitized_default_name
    (self.name.first.nil? || self.name.first.blank?) ? 'No Name Available' : sanitize_string(self.name.first).titleize
  end

  def sanitize_string(string)
    string.strip
      .gsub(/'/, '')
      .gsub(/\'/, '')
      .gsub(/,/, '')
      .gsub(/\,/, '')
      .gsub(/"/, '')
      .gsub(/\"/, '')
      .gsub(/\(/, '')
      .gsub(/\)/, '')
      .gsub(/(?:\\n)/, '')
      .gsub(/\n/, '')
      .gsub(/\\n/, '')
      .gsub(/\\/, '')
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

  def number_of_sent_emails(regenerate=false)
    if self.sent_emails.nil? || regenerate == true
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

  def number_of_incoming_emails(regenerate=false)
    if self.incoming_emails.nil? || regenerate == true
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

  def get_colleagues
    parent_organisation.has_members
  end

  def parent_organisation
    Organisation.find(self.member_of)
  end

  def works_in_sector
    parent_org = Organisation.find(self.member_of)
    SICConcept.find_class_or_subclass(parent_org.sector)
  end

  def org_location_string
    parent_org = Organisation.find(self.member_of)
    parent_org.location_string
  end

  def parent_org_country
    parent_organisation.best_guess_at_country
  end

  def parent_org_city
    parent_organisation.city
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

    def all_emails_for(uri)
      User.current_user.within {
        Tripod::SparqlClient::Query.select("
          SELECT DISTINCT ?email_uri
          WHERE {
            ?email_uri a <http://data.artsapi.com/def/arts/Email> .
            <#{uri}> <http://xmlns.com/foaf/0.1/made> ?email_uri .
          }
        ").map { |r| r["email_uri"]["value"] }
      }
    end

    def recipients_of_emails_for(uri)
      all_emails = all_emails_for(uri)

      User.current_user.within {
        Tripod::SparqlClient::Query.select("
          #{Person.query_prefixes}

          SELECT DISTINCT ?person
          WHERE {
            VALUES ?email { <#{all_emails.map(&:to_s).join("> <")}> }

            GRAPH <http://data.artsapi.com/graph/emails> {
              ?email arts:emailRecipient ?person
            }
          }
        ").map { |r| r["person"]["value"] }
      }
    end

    def connections_count_for(uri)
      recipients = recipients_of_emails_for(uri)

      query = Tripod::SparqlQuery.new("
        #{Person.query_prefixes}

        SELECT DISTINCT ?person
        WHERE {
          VALUES ?person { <#{recipients.join("> <")}> }

          GRAPH <http://data.artsapi.com/graph/emails> {
            ?email arts:emailRecipient <#{uri}> .
            ?email arts:emailSender ?person .
          }
        }
      ")

      User.current_user.within { 
        Tripod::SparqlClient::Query.select(query.as_count_query_str)[0]["tripod_count_var"]["value"].to_i
      }
    end

    # assumes connections have already been calculated
    def get_connections_count_for(uri)
      query = Tripod::SparqlQuery.new("
        #{Person.query_prefixes}

        SELECT DISTINCT ?person
        WHERE {
          GRAPH <http://data.artsapi.com/graph/people> {
            <#{uri}> arts:connection ?person .
          }

          GRAPH <http://data.artsapi.com/graph/emails> {
            ?email arts:emailRecipient <#{uri}> .
            ?email arts:emailSender ?person .
          }
        }
      ")

      User.current_user.within { 
        Tripod::SparqlClient::Query.select(query.as_count_query_str)[0]["tripod_count_var"]["value"].to_i
      }
    end

    # try one, fall back to the other
    # will throw an exception if neither is found
    def find_by_email_or_name(string)
      string.strip!
      begin
        find_by_email(string)
      rescue
        find_by_name(string)
      end
    end

    # to facilitate search
    def find_by_email(email)
      uri = get_uri_from_email(email)
      Person.find(uri)
    end

    def find_by_name(string)
      uri = User.current_user.within {
        Tripod::SparqlClient::Query.select("
          SELECT DISTINCT ?uri
          WHERE {
            VALUES ?string { \"#{string}\" \"#{string.upcase}\" \"#{string.downcase}\" \"#{string.titleize}\" }

            GRAPH <http://data.artsapi.com/graph/people> {
              { ?uri <http://www.w3.org/2000/01/rdf-schema#label> ?string . }
              UNION
              { ?uri <http://xmlns.com/foaf/0.1/name> ?string . }
            }

          }
          LIMIT 1
        ")[0]["uri"]["value"]
      }

      Person.find(uri)
    end

    def all_unhydrated
      # get unhydrated uris
      all_people_query = "
        SELECT DISTINCT ?uri
        WHERE {
          GRAPH <http://data.artsapi.com/graph/people> {
            ?uri a <http://xmlns.com/foaf/0.1/Person> .
          }
        }"

      User.current_user.within { Tripod::SparqlClient::Query.select(all_people_query) }
    end

    def total_count
      all_unhydrated.count
    end

    def all_uris
      all_unhydrated.map { |r| r["uri"]["value"] }
    end

    def all_uris_and_emails
      all_people_query = "
        #{Person.query_prefixes}

        SELECT DISTINCT ?uri ?email
        WHERE {
          GRAPH <http://data.artsapi.com/graph/people> {
            ?uri a <http://xmlns.com/foaf/0.1/Person> .
            ?uri foaf:mbox ?email .
          }
        }"

      results = User.current_user.within { Tripod::SparqlClient::Query.select(all_people_query) }

      results.map { |r| [r["uri"]["value"], r["email"]["value"]] }
    end

    # check the total emails exchanged between two people
    def total_emails_between(uri_one, uri_two)

      query = Tripod::SparqlQuery.new("
        #{Person.query_prefixes}

        SELECT ?email
        WHERE {
          VALUES ?first_person { <#{uri_one}> }
          VALUES ?second_person { <#{uri_two}> }

          GRAPH <http://data.artsapi.com/graph/emails> {
            {
              ?email arts:emailRecipient ?second_person .
              ?email arts:emailSender ?first_person .
            }
            UNION
            {
              ?email arts:emailRecipient ?first_person .
              ?email arts:emailSender ?second_person .
            }
          }
        }
      ")

      User.current_user.within { 
        Tripod::SparqlClient::Query.select(query.as_count_query_str)[0]["tripod_count_var"]["value"].to_i
      }
    end

    def connected?(uri_one, uri_two)
      query_string = "
        #{Person.query_prefixes}

        ASK {
        SELECT ?email_one ?email_two WHERE {
          VALUES ?first_person { <#{uri_one}> }
          VALUES ?second_person { <#{uri_two}> }

          GRAPH <http://data.artsapi.com/graph/emails> {
              ?email_one arts:emailRecipient ?second_person ;
                         arts:emailSender ?first_person .

              ?email_two arts:emailRecipient ?first_person ;
                         arts:emailSender ?second_person .

            }
          } LIMIT 2
        }
      "

      User.current_user.within { 
        JSON.parse(Tripod::SparqlClient::Query.query(query_string, "application/sparql-results+json"))["boolean"]
      }
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