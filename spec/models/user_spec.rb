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

end
