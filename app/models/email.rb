class Email

  include Resource

  rdf_type 'http://artsapi.com/def/arts/Email'
  graph_uri 'http://artsapi.com/graph/emails'

  field :email_sender, RDF::ARTS['emailSender']
  field :email_recipient, RDF::ARTS['emailRecipient']
  field :cc_recipient, RDF::ARTS['ccRecipient']
  field :has_domain, RDF::ARTS['hasDomain']
  field :contains_keyword, RDF::ARTS['containsKeyword']
  field :sent_at, RDF::ARTS['sentAt'], :datatype => RDF::XSD.datetime

end