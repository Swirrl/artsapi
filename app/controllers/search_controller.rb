class SearchController < ApplicationController

  before_filter :authenticate_user!

  def show
    search_string = params[:search]

    begin
      begin
        person = Person.find_by_email_or_name(search_string)
        person_uri = URI(person.uri.to_s).path

        redirect_to person_uri
      rescue
        organisation = Organisation.find_by_label(search_string)
        organisation_uri = URI(organisation.uri.to_s).path

        redirect_to organisation_uri
      end
    rescue
      flash.now[:danger] = "Sorry, that resource couldn't be found."
      render 'static/home'
    end

  end

end