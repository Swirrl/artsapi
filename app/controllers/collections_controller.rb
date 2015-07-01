class CollectionsController < ApplicationController

  before_filter :authenticate_user!

  def show

    if country_or_city_in?(params)
      @presenter = Presenters::CollectionPresenter.new(nil, collection: location_collection_for(params))
      @presenter.contains_type = :organisation
    else
      type = (params[:type] || "organisation").to_sym
      @presenter = Presenters::CollectionPresenter.new(type)
    end

    @paginated = Kaminari.paginate_array(@presenter.sorted).page(params[:page]).per(20)
  end

  private

    def country_or_city_in?(params)
      !!(params.has_key?(:country) || params.has_key?(:city))
    end

    def location_collection_for(params)
      location_type = resolve_location_type(params)

      case location_type
      when :country
        results = Organisation.all_organisations_in_country(params[:country])
        results.map { |r| Organisation.find(r[0]) }.compact
      when :city
        results = Organisation.all_organisations_in_city(params[:city])
        results.map { |r| Organisation.find(r[0]) }.compact
      end
    end

    def resolve_location_type(params)
      if params.has_key?(:country)
        :country
      elsif params.has_key?(:city)
        :city
      end
    end

end