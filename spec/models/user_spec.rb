require 'rails_helper'

describe User do

  let(:test_user) { User.new(
    email: 'jeff@example.com',
    password: 'password',
    name: 'Jeff Vader',
    ds_name_slug: 'artsapi-test'
  ) }

  let(:test_user_two) { User.new(
    email: 'jeff@example.com',
    password: 'password',
    name: 'Jeff Vader',
    ds_name_slug: 'bar'
  ) }

  describe 'attributes' do

    it { expect(test_user).to respond_to(:email) }
    it { expect(test_user).to respond_to(:password) }
    it { expect(test_user).to respond_to(:name) }
    it { expect(test_user).to respond_to(:ds_name_slug) }

  end

  describe 'validations' do
    pending
  end

  describe '#within method' do
    before do
      test_user.ds_name_slug = 'foo'
      test_user.save

      test_user.within {}
    end

    # teardown - reset to default
    after do
      test_user.ds_name_slug = 'artsapi-test'
      test_user.save

      test_user.within {}
    end

    it "should modify Tripod query endpoint" do
      expect(Tripod.query_endpoint).to eq "http://localhost:3030/foo/sparql"
    end

    it "should modify Tripod update endpoint" do
      expect(Tripod.update_endpoint).to eq "http://localhost:3030/foo/update"
    end
  end

  describe '#within method, multiple users with different dbs' do
    before do
      test_user.ds_name_slug = 'foo'
      test_user.save

      test_user.within {}
      test_user_two.within {}
    end

    # teardown - reset to default
    after do
      test_user.ds_name_slug = 'artsapi-test'
      test_user.save

      test_user.within {}
    end

    it "should modify Tripod query endpoint" do
      expect(Tripod.query_endpoint).to eq "http://localhost:3030/bar/sparql"
    end

    it "should modify Tripod update endpoint" do
      expect(Tripod.update_endpoint).to eq "http://localhost:3030/bar/update"
    end

    it "should modify Tripod query endpoint based on the user" do
      test_user.within {}
      expect(Tripod.query_endpoint).to eq "http://localhost:3030/foo/sparql"
    end

    it "should modify Tripod update endpoint based on the user" do
      test_user.within {}
      expect(Tripod.update_endpoint).to eq "http://localhost:3030/foo/update"
    end
  end

  describe "#active_jobs" do
    pending
  end

  describe "multi tenancy testing" do

    let(:user_one) { User.create(
      email: 'jeff@widgetcorp.org',
      password: 'password',
      name: 'Jeff Vader',
      ds_name_slug: 'artsapi-test'
    ) }

    let(:user_two) { User.create(
      email: 'brian@example.com',
      password: 'password',
      name: 'Brian Vader',
      ds_name_slug: 'artsapi-test-two'
    ) }

    # clear out second endpoint
    before do

      # set the controls for the heart of the second endpoint
      user_two.set_tripod_endpoints!

      # deploy pain
      Tripod::SparqlClient::Update.update('
        # delete from default graph:
        DELETE {?s ?p ?o} WHERE {?s ?p ?o};
        # delete from named graphs:
        DELETE {graph ?g {?s ?p ?o}} WHERE {graph ?g {?s ?p ?o}};
      ')
    end

    it "initially should have no people in either db" do
      User.current_user = user_one
      expect(Person.all.resources.count).to be 0

      User.current_user = user_two
      expect(Person.all.resources.count).to be 0
    end

    it "initially should have no orgs in either db" do
      User.current_user = user_one
      expect(Organisation.all.resources.count).to be 0

      User.current_user = user_two
      expect(Organisation.all.resources.count).to be 0
    end

    describe "multiple endpoints" do

      # seed one organisation and two people for each
      # then call the async data processing for both users
      before do
        user_one.save
        user_two.save
        seed_multiple_endpoint_data(user_one, user_two)
      end

      # user one should have john mcclane
      it "user_one should have its own data" do
        User.current_user = user_one
        expect(Person.find('http://data.artsapi.com/id/people/john-nyc-gov').uri.to_s).to eq 'http://data.artsapi.com/id/people/john-nyc-gov'
        expect(Person.find('http://data.artsapi.com/id/people/walter-widgetcorp-org').uri.to_s).to eq 'http://data.artsapi.com/id/people/walter-widgetcorp-org'
      end

      # jazz should not be present
      it "user_one should not have other org's data" do
        User.current_user = user_one
        expect(Person.find('http://data.artsapi.com/id/people/jazz-swirrl-com')).to be_nil
        expect(Person.find('http://data.artsapi.com/id/people/arthur-example-com')).to be_nil
      end

      # jazz should be in this graph
      it "user_two should have its own data" do
        User.current_user = user_two
        expect(Person.find('http://data.artsapi.com/id/people/jazz-swirrl-com').uri.to_s).to eq 'http://data.artsapi.com/id/people/jazz-swirrl-com'
        expect(Person.find('http://data.artsapi.com/id/people/arthur-example-com').uri.to_s).to eq 'http://data.artsapi.com/id/people/arthur-example-com'
      end

      # but john mcclane has no place here
      it "user_two should not have other org's data" do
        User.current_user = user_two
        expect(Person.find('http://data.artsapi.com/id/people/john-nyc-gov')).to be_nil
        expect(Person.find('http://data.artsapi.com/id/people/walter-widgetcorp-org')).to be_nil
      end

    end

    describe "async workers" do

      # seed one organisation and two people for each
      # then call the async data processing for both users
      # before { seed_multiple_endpoint_data(user_one, user_two) }

      pending

    end

  end

end
