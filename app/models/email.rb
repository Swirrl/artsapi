class Email < ResourceWithPresenter

  include Tripod::Resource
  extend TripodOverrides

  rdf_type 'http://data.artsapi.com/def/arts/Email'
  graph_uri 'http://data.artsapi.com/graph/emails'

  field :sender, RDF::ARTS['emailSender'], is_uri: true
  field :recipient, RDF::ARTS['emailRecipient'], is_uri: true, multivalued: true
  field :cc_recipient, RDF::ARTS['ccRecipient'], is_uri: true, multivalued: true
  field :has_subject, RDF::ARTS['emailSubject'] # not actually used but a part of the ontology
  field :has_domain, RDF::ARTS['hasDomain'], is_uri: true
  field :contains_keywords, RDF::ARTS['containsKeyword'], is_uri:true, multivalued: true
  field :sent_at, RDF::ARTS['sentAt'], :datatype => RDF::XSD.datetime

  class << self

    def total_count

      # get unhydrated uris
      all_emails_sparql = "
        SELECT DISTINCT ?uri 
        WHERE { 
          GRAPH <http://data.artsapi.com/graph/emails> { 
            ?uri a <http://data.artsapi.com/def/arts/Email> . 
          } 
        }"

      User.current_user.within { Tripod::SparqlClient::Query.select(all_emails_sparql).count }
    end

    def unique_interpersonal_edges_via_email
      all_interpersonal_edges_sparql =  "
      PREFIX arts: <http://data.artsapi.com/def/arts/>

      SELECT DISTINCT ?person_one ?person_two
      WHERE
      {
        GRAPH <http://data.artsapi.com/graph/emails> {
          {
            ?email arts:emailSender ?person_one .
            ?email arts:emailRecipient ?person_two .
          }
          UNION
          {
            ?email arts:emailSender ?person_two .
            ?email arts:emailRecipient ?person_one .
          }
        }
      }"

      User.current_user.within { Tripod::SparqlClient::Query.select(all_interpersonal_edges_sparql) }
    end

    def unique_edges_count
      unique_interpersonal_edges_via_email.count
    end

  end

end