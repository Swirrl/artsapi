class PeopleController < ApplicationController

  before_filter :authenticate_user!

  def update

    respond_to do |format|
      format.js do

        begin
          person = Person.find(params[:uri])

          person.label = params[:label] if !params[:label].blank? && !params[:label].nil?
          person.position = params[:position] if !params[:position].blank? && !params[:position].nil?

          person.save

          render nothing: true, status: 200
        rescue
          render nothing: true, status: 500
        end

      end
    end

  end

end