class ResourcesController < ApplicationController

  def show

    render text: "#{ArtsAPI::HOST}/id/#{params[:resource_type]}/#{params[:slug]}"

  end

end