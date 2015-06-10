# given some users, set the current user and dispatch to their async worker
# wait a bit to see what happens once those have done their thing
def seed_multiple_endpoint_data(user_one, user_two)

  # assume user_one is Jeff, and therefore widgetcorp
  seed_widgetcorp_data!(user_one)

  # assume user_two is Brian, and therefore example.com
  seed_example_com_data!(user_two)

  set_current_user_and_bootstrap_for(user_one)
  set_current_user_and_bootstrap_for(user_two)
  set_current_user_and_bootstrap_for(user_one)
  set_current_user_and_bootstrap_for(user_two)

  sleep 240
end

def seed_widgetcorp_data!(user)

  user.set_tripod_endpoints!

  jeff_uri = RDF::URI("http://data.artsapi.com/id/people/jeff-widgetcorp-org")
  walter_uri = RDF::URI("http://data.artsapi.com/id/people/walter-widgetcorp-org")

  email = FactoryGirl.create(:email, 
      sender: jeff_uri, 
      recipient: [RDF::URI("http://data.artsapi.com/id/people/walter-widgetcorp-org"),
      RDF::URI("http://data.artsapi.com/id/people/donny-widgetcorp-org")], 
      contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/ask')])

  email_two = FactoryGirl.create(:email, 
      sender: jeff_uri, 
      recipient: [walter_uri,
      RDF::URI("http://data.artsapi.com/id/people/donny-widgetcorp-org")], 
      contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/ask')])

  email_three = FactoryGirl.create(:email, 
      sender: walter_uri, 
      recipient: [jeff_uri, RDF::URI("http://data.artsapi.com/id/people/donny-widgetcorp-org")])

  email_four = FactoryGirl.create(:email, 
      sender: jeff_uri, 
      recipient: [RDF::URI("http://data.artsapi.com/id/people/john-nyc-gov"),
      RDF::URI("http://data.artsapi.com/id/people/donny-widgetcorp-org"), jeff_uri], 
      contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/ask')])

  email_five = FactoryGirl.create(:email, 
      sender: RDF::URI("http://data.artsapi.com/id/people/john-nyc-gov"), 
      recipient: [jeff_uri], 
      contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/planning')])

  john_mcclane = FactoryGirl.create(:person, email: 'john@nyc.gov', made: [email_five.uri])

  jeff = FactoryGirl.create(:person, made: [email.uri, email_two.uri, email_four.uri])
  walter = FactoryGirl.create(:person, email: 'walter@widgetcorp.org', made: [email_three.uri])

  organisation = FactoryGirl.create(:organisation, has_members: [jeff.uri, walter.uri])
  organisation_two = FactoryGirl.create(:organisation, uri: RDF::URI('http://data.artsapi.com/id/organisations/nyc-gov'), has_members: [john_mcclane.uri])

end

def seed_example_com_data!(user)

  user.set_tripod_endpoints!

  brian_uri = RDF::URI("http://data.artsapi.com/id/people/brian-example-com")
  arthur_uri = RDF::URI("http://data.artsapi.com/id/people/arthur-example-com")

  email = FactoryGirl.create(:email, 
      sender: brian_uri, 
      recipient: [RDF::URI("http://data.artsapi.com/id/people/arthur-example-com"),
      RDF::URI("http://data.artsapi.com/id/people/donny-example-com")], 
      contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/ask')])

  email_two = FactoryGirl.create(:email, 
      sender: brian_uri, 
      recipient: [arthur_uri,
      RDF::URI("http://data.artsapi.com/id/people/donny-example-com")], 
      contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/ask')])

  email_three = FactoryGirl.create(:email, 
      sender: arthur_uri, 
      recipient: [brian_uri, RDF::URI("http://data.artsapi.com/id/people/donny-example-com")])

  email_four = FactoryGirl.create(:email, 
      sender: brian_uri, 
      recipient: [RDF::URI("http://data.artsapi.com/id/people/jazz-swirrl-com"),
      RDF::URI("http://data.artsapi.com/id/people/donny-example-com"), brian_uri], 
      contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/ask')])

  email_five = FactoryGirl.create(:email, 
      sender: RDF::URI("http://data.artsapi.com/id/people/jazz-swirrl-com"), 
      recipient: [brian_uri], 
      contains_keywords: [RDF::URI('http://data.artsapi.com/id/keywords/keyword/planning')])

  jazz = FactoryGirl.create(:person, email: 'jazz@swirrl.com', made: [email_five.uri])

  brian = FactoryGirl.create(:person, email: 'brian@example.com', made: [email.uri, email_two.uri, email_four.uri])
  arthur = FactoryGirl.create(:person, email: 'arthur@example.com', made: [email_three.uri])

  organisation = FactoryGirl.create(:organisation, uri: RDF::URI('http://data.artsapi.com/id/organisations/example-com'), has_members: [brian.uri, arthur.uri])
  organisation_two = FactoryGirl.create(:organisation, uri: RDF::URI('http://data.artsapi.com/id/organisations/swirrl-com'), has_members: [jazz.uri])

end

# be aware! in the context of a http request cycle, current user will be lost
# but it will not be lost in the context of a background worker.
# this method mocks an http request to the process data endpoint 
# and its side effects
# it is not meant to represent a background worker hitting
# the http stack in that regard; a separate test for nilling the current_user
# in the middleware is also needed
def set_current_user_and_bootstrap_for(user)
  User.current_user = user
  Organisation.bootstrap_owner_or_largest_org!
  #User.current_user = nil
end