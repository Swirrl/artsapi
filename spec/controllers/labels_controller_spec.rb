require 'rails_helper'

describe LabelsController do
  render_views

  it_behaves_like "given a db with two organisations" do

    context "finding labels" do

      before { sign_in user }

      it "responds with 200" do
        post :find, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org', format: :json
        expect(response.status).to eq 200
      end

      it "returns the resource label" do
        post :find, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org', format: :json
        expect(!!(response.body.match(/Jeff Lebowsk[a-z]+/)[0])).to eq true
      end

    end

    context 'showing a non-existent resource' do

      before { sign_in user }

      it "responds with 404" do
        post :find, uri: 'http://data.artsapi.com/id/people/darth-vader', format: :json
        expect(response.status).to eq 404
      end

    end

  end

end