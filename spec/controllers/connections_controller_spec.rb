require 'rails_helper'

describe ConnectionsController do
  render_views

  it_behaves_like "given a db with two organisations" do

    describe "generating connections with correct params" do

      before { sign_in user }

      it "responds with 202" do
        post :generate, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org', format: :json
        expect(response.status).to eq 202
      end

    end

    describe "generating connections with incorrect params" do

      before { sign_in user }

      it "responds with 404" do
        post :generate, uri: 'http://data.artsapi.com/id/people/darth-vader', format: :json
        expect(response.status).to eq 404
      end

    end

    describe "#find with correct params" do

      before { sign_in user }

      it "responds with 200" do
        post :find, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org', format: :json
        expect(response.status).to eq 200
        expect(response.body).not_to be_empty
      end

    end

    describe "#distribution with correct params" do

      before { sign_in user }

      it "responds with 200" do
        post :distribution, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org'
        expect(response.status).to eq 200
      end

      it "body is not empty" do
        post :distribution, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org'
        expect(response.body).not_to be_empty
      end

      it "body is valid csv string" do
        post :distribution, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org'
        expect(response.body).to eq "occurrences,emails\n"
      end

    end

    describe "#visualise_person with correct params" do

      before do
        jeff.get_connections!
        sign_in user
      end

      it "responds with 200" do
        post :visualise_person, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org'
        expect(response.status).to eq 200
      end

      it "body is not empty" do
        post :visualise_person, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org'
        expect(response.body).not_to be_empty
      end

      it "body is correctly structured json" do
        post :visualise_person, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org'
        body = JSON.parse(response.body)
        nodes = body["nodes"]
        links = body["links"]
        expect(nodes).not_to be_empty
        expect(links).not_to be_empty
      end

      it "contains other people" do
        post :visualise_person, uri: 'http://data.artsapi.com/id/people/jeff-widgetcorp-org'
        body = JSON.parse(response.body)
        nodes = body["nodes"]
        node_uris = nodes.map { |n| n["uri"] }
        expect(node_uris).to include "http://data.artsapi.com/id/people/walter-widgetcorp-org"
      end

    end

    describe "#visualise_organisation with correct params" do

      before do
        jeff.get_connections!
        sign_in user
      end

      it "responds with 200" do
        post :visualise_organisation, uri: 'http://data.artsapi.com/id/organisations/widgetcorp-org'
        expect(response.status).to eq 200
      end

      it "body is not empty" do
        post :visualise_organisation, uri: 'http://data.artsapi.com/id/organisations/widgetcorp-org'
        expect(response.body).not_to be_empty
      end

      it "body is correctly structured json" do
        post :visualise_organisation, uri: 'http://data.artsapi.com/id/organisations/widgetcorp-org'
        body = JSON.parse(response.body)
        nodes = body["nodes"]
        links = body["links"]
        expect(nodes).not_to be_empty
        expect(links).not_to be_empty
      end

    end

  end

end