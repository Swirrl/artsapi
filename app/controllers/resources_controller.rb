class ResourcesController < ApplicationController

  before_filter :authenticate_user!

  def show

    @presenter = Dispatcher.load_presenter_with(params)

    if @presenter.nil?
      render 'public/404', status: 404
    else
      render :show
    end

  end

end