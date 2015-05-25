class OrganisationsController < ApplicationController

  before_filter :authenticate_user!

  def update

    respond_to do |format|
      format.js do

        begin
          org = Organisation.find(params[:uri])

          org.label = params[:label] if !params[:label].blank? && !params[:label].nil?
          org.country = params[:country] if !params[:country].blank? && !params[:country].nil?
          org.city = params[:city].strip.downcase.titleize if !params[:city].blank? && !params[:city].nil?
          org.sector = params[:sector] if !params[:sector].blank? && !params[:sector].nil?

          org.save

          render nothing: true, status: 200
        rescue
          render nothing: true, status: 500
        end

      end
    end

  end

end