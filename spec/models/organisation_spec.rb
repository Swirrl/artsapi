require 'rails_helper'

describe 'Organisation' do
  it_behaves_like "given a db with two organisations" do

    # mock a signed-in user for DB queries
    before { User.current_user = user }

    context "instance methods" do

      describe "#sector_label" do
        before do
          bootstrap_sic!
          sector = SIC::Class.find('http://swirrl.com/id/sic/0116')

          organisation.sector = sector.uri
          organisation.save
        end

        it { expect(organisation.sector_label).to eq "Growing of fibre crops" }
      end

      describe "sic extensions for use by organisations" do
        before { bootstrap_sic! }

        # look up the voluntary/charitable extensions by different methods
        it { expect(SIC::Class.find('http://swirrl.com/id/sic/10020').label).to eq "Voluntary or unpaid activities n.e.c." }
        it { expect(SICConcept.find_class_or_subclass("http://swirrl.com/id/sic/10010").label).to eq "Charitable activities" }

        # test all the arts category extensions are there
        it { expect(SICConcept.all_classes_and_subclasses.map(&:uri).to_s).to include ("http://swirrl.com/id/sic/90031") }
        it { expect(SICConcept.all_classes_and_subclasses.map(&:uri).to_s).to include ("http://swirrl.com/id/sic/90011") }
        it { expect(SICConcept.all_classes_and_subclasses.map(&:uri).to_s).to include ("http://swirrl.com/id/sic/90032") }
        it { expect(SICConcept.all_classes_and_subclasses.map(&:uri).to_s).to include ("http://swirrl.com/id/sic/90012") }
        it { expect(SICConcept.all_classes_and_subclasses.map(&:uri).to_s).to include ("http://swirrl.com/id/sic/90013") }
        it { expect(SICConcept.all_classes_and_subclasses.map(&:uri).to_s).to include ("http://swirrl.com/id/sic/90033") }
      end

      describe "#location_string" do
        before do
          organisation.city = "Manchester"
          organisation.country = "United Kingdom"
          organisation.save
        end

        it { expect(organisation.location_string).to eq "City: Manchester, Country: United Kingdom" }
      end

      describe "#get_top_subject_areas" do

        let!(:email_six) { 
          FactoryGirl.create(:email, 
            sender: jeff_uri, 
            recipient: [RDF::URI("http://data.artsapi.com/id/people/walter-widgetcorp-org"),
            RDF::URI("http://data.artsapi.com/id/people/donny-widgetcorp-org")], 
            contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/ask')]) }

        let!(:email_seven) { 
          FactoryGirl.create(:email, 
            sender: jeff_uri, 
            recipient: [walter_uri,
            RDF::URI("http://data.artsapi.com/id/people/donny-widgetcorp-org")], 
            contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/planning')]) }

        before do
          bootstrap_keywords!
          seed_keyword_mentions_for(organisation)
        end

        #it { expect(organisation.get_top_subject_areas.length).to eq 1 }
        #it { expect(organisation.get_top_subject_areas.first).to eq 'http://data.artsapi.com/id/keywords/category/developing' }
      end

      describe "#get_common_subject_areas" do

        let!(:email_six) { 
          FactoryGirl.create(:email, 
            sender: jeff_uri, 
            recipient: [RDF::URI("http://data.artsapi.com/id/people/walter-widgetcorp-org"),
            RDF::URI("http://data.artsapi.com/id/people/donny-widgetcorp-org")], 
            contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/ask')]) }

        let!(:email_seven) { 
          FactoryGirl.create(:email, 
            sender: jeff_uri, 
            recipient: [walter_uri,
            RDF::URI("http://data.artsapi.com/id/people/donny-widgetcorp-org")], 
            contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/planning')]) }

        before do
          bootstrap_keywords!
          seed_keyword_mentions_for(organisation)
        end

        #it { expect { organisation.get_common_subject_areas! }.to change(organisation, :common_subject_areas) }
      end

      describe "#get_top_keywords" do
        before do
          bootstrap_keywords!
          seed_keyword_mentions_for(organisation)
        end

        it { expect(organisation.get_top_keywords.length).to eq 2 }
        it { expect(organisation.get_top_keywords.first[0]).to eq 'Ask' }
        it { expect(organisation.get_top_keywords.first[1]).to eq 4 }
        it { expect(organisation.get_top_keywords.second[0]).to eq 'Planning' }
        it { expect(organisation.get_top_keywords.second[1]).to eq 1 }
      end

      describe "#get_common_keywords" do
        before do
          bootstrap_keywords!
          seed_keyword_mentions_for(organisation)
        end

        it { expect { organisation.get_common_keywords! }.to change(organisation, :common_keywords) }
      end

      describe "#members_with_more_than_x_connections" do
        let!(:email_six) {
          FactoryGirl.create(:email, 
            sender: 'http://data.artsapi.com/id/people/donny-widgetcorp-org',
            recipient: [jeff_uri]) }
        let!(:donny) { FactoryGirl.create(:person, email: 'donny@widgetcorp.org', made: [email_six.uri]) }

        before { organisation.generate_all_connections! }

        it { expect(organisation.members_with_more_than_x_connections(1).length).to be 1 }
        it { expect(organisation.members_with_more_than_x_connections(1)).to include jeff_uri }
        it { expect(organisation.members_with_more_than_x_connections(1)).not_to include walter_uri }
      end

      describe "best_guess_at_country" do
        let!(:uk_org) { FactoryGirl.create(:organisation, uri: RDF::URI('http://data.artsapi.com/id/organisations/foouniversity-ac-uk'), label: 'foouniversity-ac-uk') }

        it { expect(uk_org.best_guess_at_country).to eq "United Kingdom" }
      end

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

      describe "sidekiq tasks" do

        it "should enqueue a visualisation worker" do
          jeff.get_connections!
          expect {
            Sidekiq::Testing.fake! do
              organisation.set_visualisation_graph_async
            end
          }.to change(OrganisationsWorker.jobs, :size).by(1)
        end

        it "#generate_connections_async! should enqueue jobs" do
          expect {
            Sidekiq::Testing.fake! do
              organisation.generate_connections_async!
            end
          }.to change(ConnectionsWorker.jobs, :size).by(2)
        end

        it "#generate_visualisations_async! should enque jobs" do
          expect {
            Sidekiq::Testing.fake! do
              organisation.generate_visualisations_async!
            end
          }.to change(PeopleWorker.jobs, :size).by(2)
          expect {
            Sidekiq::Testing.fake! do
              organisation.generate_visualisations_async!
            end
          }.to change(OrganisationsWorker.jobs, :size).by(1)
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