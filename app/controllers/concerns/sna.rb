module SNA

  extend ActiveSupport::Concern

  def self.network_density
    n = Person.total_count
    potential_connections = (n * (n - 1)) / 2
    actual_connections = Email.unique_interpersonal_edges_via_email
    actual_connections / potential_connections
  end

  def self.indegree_outdegree_for_person(uri)
    person = Person.find(uri)

    indegree = person.get_incoming_mail_senders
    outdegree = person.get_recipients_of_emails

    [indegree, outdegree]
  end

  def self.degree_centrality_for_person(uri)
    person = Person.find(uri)
    total_nodes = Person.total_count

    all_edges_count = all_edges_for_person(uri)

    all_edges_count / total_nodes - 1
  end

  def self.all_edges_for_person(uri) 
    person = Person.find(uri)

    all_edges_for_node = []
    all_edges_for_node << person.get_incoming_mail_senders
    all_edges_for_node << person.get_recipients_of_emails
    all_edges_for_node.flatten!.uniq!

    all_edges_for_node.count
  end

end