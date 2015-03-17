require 'rails_helper'

describe ResourcesController do
  render_views

  it_behaves_like "given a db with two organisations" do

    describe "finding labels" do
      pending
    end

  end

end