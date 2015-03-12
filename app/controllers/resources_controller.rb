class ResourcesController < ApplicationController

  def show

    @presenter = Dispatcher.load_presenter_with(params)

    if @presenter.nil?
      render 'public/404'
    else
      render :show
    end

  end

end