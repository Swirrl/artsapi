namespace :db do

  desc 'Seed the db for an Organisation; usage: rake db:generate_connections[http://data.artsapi.com/id/organisation/futureeverything-org]'

  task :generate_connections, [:org_uri] => [:environment] do |t, args|
    organisation = Organisation.find(args[:org_uri])
    organisation.generate_all_connections!
  end

end