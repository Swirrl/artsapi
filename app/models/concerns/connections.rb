require 'memoist'
module Connections

  extend ActiveSupport::Concern
  extend Memoist

  # writes to db
  def get_connections!
    connections = calculate_connections
    write_connections(connections)

    self.connections
  end

  # pure read
  def get_connections
    calculate_connections
  end
  memoize :get_connections

  # async
  def generate_connections_async
    ::ConnectionsWorker.perform_in(50.seconds, self.uri.to_s)
  end

  def get_recipients_of_emails
    User.current_user.within {
      Tripod::SparqlClient::Query.select("
        #{Person.query_prefixes}

        SELECT DISTINCT ?person
        WHERE {
          VALUES ?email { <#{self.all_emails.map(&:uri).join("> <")}> }

          GRAPH <http://data.artsapi.com/graph/emails> {
            ?email arts:emailRecipient ?person
          }
        }
      ").map { |r| r["person"]["value"] }
    }
  end
  memoize :get_recipients_of_emails

  def get_incoming_mail_senders
    User.current_user.within {
      Tripod::SparqlClient::Query.select("
        #{Person.query_prefixes}

        SELECT DISTINCT ?person
        WHERE {
          VALUES ?person { <#{self.connections.map(&:to_s).join("> <")}> }

          GRAPH <http://data.artsapi.com/graph/emails> {
            ?email arts:emailRecipient <#{self.uri}>.
            ?email arts:emailSender ?person .
          }
        }
        ").map { |r| r["person"]["value"] }
    }
  end

  def calculate_connections
    connection_set = []
    recipients = self.get_recipients_of_emails

    filtered =  User.current_user.within { 
      Tripod::SparqlClient::Query.select("
      #{Person.query_prefixes}

      SELECT DISTINCT ?person
      WHERE {
        VALUES ?person { <#{recipients.join("> <")}> }

        GRAPH <http://data.artsapi.com/graph/emails> {
          ?email arts:emailRecipient <#{self.uri}>.
          ?email arts:emailSender ?person .
        }

      }
      ").map { |r| r["person"]["value"] } 
    }

    filtered
  end
  memoize :calculate_connections

  # requires you to know the connections in advance
  def calculate_email_density
    results = []

    self.connections.each do |conn|
      query = Tripod::SparqlQuery.new("
        #{Person.query_prefixes}

        SELECT ?email
        WHERE {
          VALUES ?other_person { <#{conn.to_s}> }

          GRAPH <http://data.artsapi.com/graph/emails> {
            {
              ?email arts:emailRecipient ?other_person .
              ?email arts:emailSender <#{self.uri}> .
            }
            UNION
            {
              ?email arts:emailRecipient <#{self.uri}> .
              ?email arts:emailSender ?other_person .
            }
          }
        }
        ")

      count = User.current_user.within {
        Tripod::SparqlClient::Query.select(query.as_count_query_str)[0]["tripod_count_var"]["value"].to_i
      }

      results << [conn.to_s, count]
    end

    results
  end

  # for views or usage where order matters, i.e. not graphs
  def sorted_email_density
    self.calculate_email_density.sort { |a, b| b[1] <=> a[1] }
  end

  # write connections between foaf:People and
  # write connections between org:Organizations
  def write_connections(connections)

    # write the connections on this Person
    Person.write_connections_on(self, connections)

    connections.each do |conn|
      other_person = Person.find(conn)
      Person.write_connections_on(other_person, self.uri.to_s)
      Organisation.write_link(self.member_of, other_person.member_of)
    end

  end

end