class CollectionsController < ApplicationController

  before_filter :authenticate_user!

  def show
    type = (params[:type] || "organisation").to_sym

    @presenter = Presenters::CollectionPresenter.new(type)

    @paginated = Kaminari.paginate_array(@presenter.sorted).page(params[:page]).per(20)
  end

end