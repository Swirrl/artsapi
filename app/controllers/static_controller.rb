class StaticController < ApplicationController

  before_filter :authenticate_user!, only: [:home]

  def home
  end

  def about
  end

  def contact
  end

end