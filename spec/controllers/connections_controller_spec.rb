require 'rails_helper'

describe ConnectionsController do
  render_views

  it_behaves_like "given a db with two organisations" do

    describe "generating connections" do
      pending
    end

  end

end