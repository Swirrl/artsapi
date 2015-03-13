module Connections

  extend ActiveSupport::Concern

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

  # async
  def generate_connections_async
    #worker = ::ConnectionsWorker.new
    #::ConnectionsWorker.perform_in(1.minute, self.uri.to_s)
    ::ConnectionsWorker.perform_in(50.seconds, self.uri.to_s)
  end

  def get_recipients_of_emails
    Tripod::SparqlClient::Query.select("
      #{Person.query_prefixes}

      SELECT DISTINCT ?person
      WHERE {
        VALUES ?email { <#{self.all_emails.map(&:uri).join("> <")}> }

        ?person a foaf:Person .
        ?email a arts:Email .

        GRAPH <http://artsapi.com/graph/emails> {
          ?email arts:emailRecipient ?person
        }
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

  def calculate_connections
    connection_set = []
    recipients = self.get_recipients_of_emails

    filtered = Tripod::SparqlClient::Query.select("
      #{Person.query_prefixes}

      SELECT DISTINCT ?person
      WHERE {
        VALUES ?person { <#{recipients.join("> <")}> }

        ?person a foaf:Person .
        ?email a arts:Email .

        GRAPH <http://artsapi.com/graph/emails> {
          ?email arts:emailRecipient <#{self.uri}>.
          ?email arts:emailSender ?person .
        }

      }
      ").map { |r| r["person"]["value"] }

    filtered
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