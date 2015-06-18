module SNA

  extend ActiveSupport::Concern

  def self.potential_connections
    no_of_nodes = Person.total_count
    (no_of_nodes * (no_of_nodes - 1)) / 2
  end

  def self.network_density
    actual_connections = Email.unique_edges_count
    actual_connections.to_f / potential_connections.to_f
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

    all_associated_nodes = all_edges_for_person(uri)

    all_associated_nodes.to_f / (total_nodes.to_f - 1.0)
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