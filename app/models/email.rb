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

  end

end