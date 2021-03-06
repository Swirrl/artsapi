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
        o = Organisation.find(uri)
        o.presenter_type = Presenters::OrganisationPresenter
        o.presenter
      when :people
        p = Person.find(uri)
        p.presenter_type = Presenters::PersonPresenter
        p.presenter
      else
        self.wildcard_find(uri)
      end
    rescue Tripod::Errors::ResourceNotFound
      nil
    end

  end

  def self.find_and_cast(resource_uri)
    type_string = URI(resource_uri).path.to_s.match(/id\/.+\//)[0][3..-2] rescue nil

    case type_string
    when "domains"
      Domain.find(resource_uri)
    when "emails"
      Emails.find(resource_uri)
    when "email_accounts"
      EmailAccount.find(resource_uri)
    when "organisations"
      Organisation.find(resource_uri)
    when "people"
      Person.find(resource_uri)
    else # it is nil or malformed
      raise Tripod::Errors::ResourceNotFound
    end
  end

  def self.wildcard_find(uri)
    resource = User.current_user.within {
      Tripod::SparqlClient::Query.select("
      SELECT DISTINCT ?uri
      WHERE {
        <#{uri.to_s}> ?p ?o .
      }
      LIMIT 1
      ")[0]["uri"]["value"] rescue nil
    }

    resource.hydrate! unless resource.nil?
  end

end