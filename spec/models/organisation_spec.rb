require 'rails_helper'

describe 'Organisation' do
  it_behaves_like "given a db with two organisations" do

    context "instance methods" do

      describe "#generate_all_connections" do
        before { @connections = organisation.generate_all_connections! }

        it "should have a presenter" do
          expect(organisation.presenter).not_to be nil
        end

        it "should return a flattened array of results" do
          expect(@connections.empty?).to be false
        end

        it "should return the correct number of results" do
          expect(@connections.length).to eq 3
        end

        it "should have generated connections on its first member" do
          j = Person.find(jeff_uri)
          expect(j.connections.empty?).to be false
        end

        it "should have generated connections on its second member" do
          w = Person.find(walter_uri)
          expect(w.connections.empty?).to be false
        end

      end

    end

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
end