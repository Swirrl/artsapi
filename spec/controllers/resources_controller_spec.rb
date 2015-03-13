require 'rails_helper'

describe ResourcesController do
  render_views

  it_behaves_like "given a db with two organisations" do

    context 'showing a valid resource' do

      it "responds with 200" do
        get :show, resource_type: 'people', slug: 'jeff-widgetcorp-org', format: 'html'
        expect(response.status).to eq 200
      end

    end

    context 'showing a non-existent resource' do

      it "responds with 404" do
        get :show, resource_type: 'people', slug: 'slug', format: 'html'
        expect(response.status).to eq 404
      end

    end

  end

end