module Dispatcher

  extend ActiveSupport::Concern

  def self.load_presenter_with(params)
    type = params[:resource_type].underscore.to_sym
    uri = RDF::URI("#{ArtsAPI::HOST}/id/#{params[:resource_type]}/#{params[:slug]}")

    begin
      case type
      when :domains
        Domain.find(uri).presenter
      when :emails
        Email.find(uri).presenter
      when :email_accounts
        EmailAccount.find(uri).presenter
      when :organisations
        Organisation.find(uri).presenter
      when :people
        Person.find(uri).presenter
      else
        self.wildcard_find(uri)
      end
    rescue Tripod::Errors::ResourceNotFound
      nil
    end

  end

  def self.wildcard_find(uri)
    resource = Tripod::SparqlClient::Query.select("
      SELECT DISTINCT ?uri
      WHERE {
        <#{uri.to_s}> ?p ?o .
      }
      LIMIT 1
      ")

    resource.hydrate!
  end

end