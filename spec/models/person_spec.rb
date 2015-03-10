require 'rails_helper'

describe 'Person' do

  let(:jeff_uri) { RDF::URI("http://artsapi.com/id/people/jeff-widgetcorp-org") }
  let(:walter_uri) { RDF::URI("http://artsapi.com/id/people/walter-widgetcorp-org") }

  let(:email) { 
    FactoryGirl.create(:email, 
      sender: jeff_uri, 
      recipient: [RDF::URI("http://artsapi.com/id/people/walter-widgetcorp-org"),
      RDF::URI("http://artsapi.com/id/people/donny-widgetcorp-org")], 
      contains_keywords: [RDF::URI('http://artsapi.com/id/keywords/keyword/ask')]) }

  let(:email_two) { 
    FactoryGirl.create(:email, 
      sender: jeff_uri, 
      recipient: [RDF::URI("http://artsapi.com/id/people/walter-widgetcorp-org"),
      RDF::URI("http://artsapi.com/id/people/donny-widgetcorp-org")], 
      contains_keywords: [RDF::URI('http://artsapi.com/id/keywords/keyword/ask')]) }

  let(:email_three) { 
    FactoryGirl.create(:email, 
      sender: walter_uri, 
      recipient: [RDF::URI("http://artsapi.com/id/people/jeff-widgetcorp-org"), RDF::URI("http://artsapi.com/id/people/donny-widgetcorp-org")]) }

  let(:jeff) { FactoryGirl.create(:person, made: [email.uri, email_two.uri]) }
  let(:walter) { FactoryGirl.create(:person, email: 'walter@widgetcorp.org', made: [email_three.uri]) }

  let(:organisation) { FactoryGirl.create(:organisation, has_members: [jeff.uri, walter.uri]) }
  let(:domain) { FactoryGirl.create(:domain) }

  let(:keyword_two) { FactoryGirl.create(:keyword, 
    uri: RDF::URI('http://artsapi.com/id/keywords/keyword/planning'), 
    label: 'Planning', 
    in_sub_category: RDF::URI('http://artsapi.com/id/keywords/subcategory/operational')) }

  context "validations" do

    it "should have a uri" do
      expect(walter.uri.to_s).to eq("http://artsapi.com/id/people/walter-widgetcorp-org")
    end

    it "should have an rdf type" do
      expect(walter.rdf_type.first).to eq(RDF::FOAF['Person'])
    end

    it "should have a named graph" do
      expect(walter.graph_uri).to eq(RDF::URI("http://artsapi.com/graph/people"))
    end

  end


  context "instance methods" do

    let(:bad_name) { FactoryGirl.create(:person, name: ["The \n dude", "Jeff Lebowski"]) }

    before { organisation; email; email_two }

    it "should be able to find a better name" do
      expect(bad_name.human_name).to eq("Jeff Lebowski")
    end

    it "should be able to get number of sent emails" do
      expect(jeff.number_of_sent_emails).to eq(2)
    end

    it "should be able to get contained keywords" do
      expect(jeff.sorted_keywords.first[0]).to eq('Ask')
    end

    it "should be able to get colleagues" do
      expect(jeff.get_colleagues).to include(walter.uri)
    end

  end


  context "class methods" do

    # this actually uses methods in the Connections concern
    # as well as a class method on Person to write connections
    describe "connections" do

      before do
        jeff
        walter
        email
        email_two
        email_three
        organisation
      end

      describe "before writing" do

        it "array should be empty" do
          expect(jeff.connections.empty?).to be true
        end

      end

      describe "after writing" do

        before do
          jeff.get_connections
        end

        it "array should be populated" do
          expect(jeff.connections.empty?).to be false
          expect(jeff.connections).to include walter.uri
        end

        it "should write on other foaf:People" do
          expect(walter.connections.empty?).to be false
          expect(walter.connections).to include jeff.uri
        end

        it "should write linked_to field on org:Organisations" do
          pending "more factories needed to test this"
          expect(organisation.linked_to).to include organisation_two
        end

      end

    end

  end

end