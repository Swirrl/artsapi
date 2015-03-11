require 'rails_helper'

describe 'Organisation' do

  let!(:organisation) { FactoryGirl.create(:organisation) }
  let!(:organisation_two) { FactoryGirl.create(:organisation, uri: RDF::URI('http://artsapi.com/id/organisations/nyc-gov')) }
  let(:org_uri) { organisation.uri }
  let(:org_two_uri) { organisation_two.uri }

  context "class methods" do

    describe "#write_link" do

      before { Organisation.write_link(organisation.uri, organisation_two.uri) }

      it "should write the link on Organisation one" do
        organisation = Organisation.find(org_uri)
        expect(organisation.linked_to).to include organisation_two.uri
      end

      it "should write the link on Organisation two" do
        organisation_two = Organisation.find(org_two_uri)
        expect(organisation_two.linked_to).to include organisation.uri
      end

    end

  end

end