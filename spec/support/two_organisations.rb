shared_examples_for "given a db with two organisations" do
  let(:jeff_uri) { RDF::URI("http://artsapi.com/id/people/jeff-widgetcorp-org") }
  let(:walter_uri) { RDF::URI("http://artsapi.com/id/people/walter-widgetcorp-org") }

  let!(:email) { 
    FactoryGirl.create(:email, 
      sender: jeff_uri, 
      recipient: [RDF::URI("http://artsapi.com/id/people/walter-widgetcorp-org"),
      RDF::URI("http://artsapi.com/id/people/donny-widgetcorp-org")], 
      contains_keywords: [RDF::URI('http://artsapi.com/id/keywords/keyword/ask')]) }

  let!(:email_two) { 
    FactoryGirl.create(:email, 
      sender: jeff_uri, 
      recipient: [walter_uri,
      RDF::URI("http://artsapi.com/id/people/donny-widgetcorp-org")], 
      contains_keywords: [RDF::URI('http://artsapi.com/id/keywords/keyword/ask')]) }

  let!(:email_three) { 
    FactoryGirl.create(:email, 
      sender: walter_uri, 
      recipient: [jeff_uri, RDF::URI("http://artsapi.com/id/people/donny-widgetcorp-org")]) }

  let!(:email_four) { 
    FactoryGirl.create(:email, 
      sender: jeff_uri, 
      recipient: [RDF::URI("http://artsapi.com/id/people/john-nyc-gov"),
      RDF::URI("http://artsapi.com/id/people/donny-widgetcorp-org"), jeff_uri], 
      contains_keywords: [RDF::URI('http://artsapi.com/id/keywords/keyword/ask')]) }

  let!(:email_five) { 
    FactoryGirl.create(:email, 
      sender: RDF::URI("http://artsapi.com/id/people/john-nyc-gov"), 
      recipient: [jeff_uri], 
      contains_keywords: [RDF::URI('http://artsapi.com/id/keywords/keyword/planning')]) }

  let!(:john_mcclane) { FactoryGirl.create(:person, email: 'john@nyc.gov', made: [email_five.uri]) }

  let!(:jeff) { FactoryGirl.create(:person, made: [email.uri, email_two.uri, email_four.uri]) }
  let!(:walter) { FactoryGirl.create(:person, email: 'walter@widgetcorp.org', made: [email_three.uri]) }

  let!(:organisation) { FactoryGirl.create(:organisation, has_members: [jeff.uri, walter.uri]) }
  let!(:organisation_two) { FactoryGirl.create(:organisation, uri: RDF::URI('http://artsapi.com/id/organisations/nyc-gov'), has_members: [john_mcclane.uri]) }

  let(:org_uri) { organisation.uri }
  let(:org_two_uri) { organisation_two.uri }
end