require 'rails_helper'

describe 'Person' do
  it_behaves_like "given a db with two organisations" do

    let(:domain) { FactoryGirl.create(:domain) }

    let(:keyword_two) { FactoryGirl.create(:keyword, 
      uri: RDF::URI('http://data.artsapi.com/id/keywords/keyword/planning'), 
      label: 'Planning', 
      in_sub_category: RDF::URI('http://data.artsapi.com/id/keywords/subcategory/operational')) }

    context "validations" do

      it "should have a uri" do
        expect(walter.uri.to_s).to eq("http://data.artsapi.com/id/people/walter-widgetcorp-org")
      end

      it "should have an rdf type" do
        expect(walter.rdf_type.first).to eq(RDF::FOAF['Person'])
      end

      it "should have a named graph" do
        expect(walter.graph_uri).to eq(RDF::URI("http://data.artsapi.com/graph/people"))
      end

    end


    context "instance methods" do

      let(:bad_name) { FactoryGirl.create(:person, name: ["The \n dude", "Jeff Lebowski", "jeff"]) }
      let(:bad_name_two) { FactoryGirl.create(:person, name: ["jeff \n Lebowski"]) }

      before do 
        organisation

        # let's ape what the grafter pipeline does
        emails = jeff.made.map { |uri| Email.find(uri) }
        keywords = emails.map(&:contains_keywords)
        jeff.mentioned_keywords = keywords.flatten.map(&:to_s)
      end

      it "should have a presenter" do
        expect(jeff.presenter).not_to be nil
      end

      it "should be able to find a better name" do
        expect(bad_name.human_name).to eq("Jeff Lebowski")
      end

      it "should be able to get number of sent emails" do
        expect(jeff.number_of_sent_emails).to eq(3)
      end

      it "should be able to get contained keywords" do
        expect(jeff.sorted_keywords.first[0]).to eq('Ask')
      end

      it "should be able to get colleagues" do
        expect(jeff.get_colleagues).to include(walter.uri)
      end

    end


    context "class methods" do

      describe "#get_uri_from_email" do

        it { expect(Person.get_uri_from_email("kaneda@capsules.jp")).to eq "http://data.artsapi.com/id/people/kaneda-capsules-jp" }
        it { expect(Person.get_uri_from_email("kaneda@capsules.jp ")).to eq "http://data.artsapi.com/id/people/kaneda-capsules-jp" }
        it { expect(Person.get_uri_from_email(" kaneda@capsules.jp ")).to eq "http://data.artsapi.com/id/people/kaneda-capsules-jp" }
      end

      describe "#get_rdf_uri_from_email" do
        it { expect(Person.get_rdf_uri_from_email("kaneda@capsules.jp")).to eq RDF::URI("http://data.artsapi.com/id/people/kaneda-capsules-jp") }
      end

      # this actually uses methods in the Connections concern
      # as well as a class method on Person to write connections
      describe "#get_connections!" do

        before { organisation }

        describe "before writing" do

          it "array should be empty" do
            expect(jeff.connections.empty?).to be true
          end

        end

        describe "after writing" do

          before { jeff.get_connections! }

          it "connections field should be populated" do
            expect(jeff.connections.empty?).to be false
            expect(jeff.connections).to include walter.uri
          end

          it "should write on other foaf:People" do
            walter = Person.find(walter_uri)
            expect(walter.connections.empty?).to be false
            expect(walter.connections).to include jeff.uri
          end

          it "should not write a connection to itself" do
            expect(jeff.connections.empty?).to be false
            expect(jeff.connections).not_to include jeff.uri
          end

          it "should write linked_to field on org:Organisations" do
            org_uri = organisation.uri
            organisation = Organisation.find(org_uri)
            expect(organisation.linked_to).to include organisation_two.uri
          end

          it "should not link an org:Organisation to itself" do
            org_uri = organisation.uri
            organisation = Organisation.find(org_uri)
            expect(organisation.linked_to.empty?).to be false
            expect(organisation.linked_to).not_to include org_uri
          end

        end

      end

      describe "#get_connections" do

        before do
          organisation
          @connections = jeff.get_connections
        end

        it "return array should be populated" do
          expect(@connections.empty?).to be false
          expect(@connections).to include walter.uri
        end

        it "connections field should not be populated" do
          expect(jeff.connections.empty?).to be true
          expect(jeff.connections).not_to include walter.uri
        end

        it "should not write on other foaf:People" do
          walter = Person.find(walter_uri)
          expect(walter.connections.empty?).to be true
          expect(walter.connections).not_to include jeff.uri
        end

        it "should not write a connection to itself" do
          expect(jeff.connections.empty?).to be true
          expect(jeff.connections).not_to include jeff.uri
        end

        it "should not write linked_to field on org:Organisations" do
          org_uri = organisation.uri
          organisation = Organisation.find(org_uri)
          expect(organisation.linked_to).not_to include organisation_two.uri
        end

      end

      describe "#calculate_email_density" do

        before { jeff.get_connections! }

        it "should not be empty" do
          expect(jeff.calculate_email_density).not_to be_empty
        end

        it "should return an array of values" do
          array = jeff.calculate_email_density
          first_positions = array.map{|i| i[0]}
          second_positions = array.map{|i| i[1]}

          expect(first_positions.length).to eq 2
          expect(first_positions).to include "http://data.artsapi.com/id/people/walter-widgetcorp-org"
          expect(first_positions).to include "http://data.artsapi.com/id/people/john-nyc-gov"

          expect(second_positions.length).to eq 2
          expect(second_positions.first.is_a?(Integer)).to eq true
          expect(second_positions.second.is_a?(Integer)).to eq true
        end
      end

      describe "#sorted_email_density" do

        before { jeff.get_connections! }

        it "should not be empty" do
          expect(jeff.sorted_email_density).not_to be_empty
        end

        it "should contain expected values" do
          array = jeff.sorted_email_density

          expect(array.first[0]).to eq "http://data.artsapi.com/id/people/walter-widgetcorp-org"
          expect(array.last[0]).to eq "http://data.artsapi.com/id/people/john-nyc-gov"
          expect(array.first[1]).to be > array.last[1]
        end
      end

      describe "#total_count" do

        it { expect(Person.total_count).to eq 3 }

      end

    end

  end
end