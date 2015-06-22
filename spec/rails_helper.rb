# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
#require 'devise'
require 'sidekiq/testing'
require 'capybara/poltergeist'

include Warden::Test::Helpers
Warden.test_mode!

# we want sidekiq to run against redis
# and run immediately; the queue is cleared between tests
Sidekiq::Testing.inline!

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.orm = "mongoid"

# Capybara.javascript_driver = :webkit
# Capybara.javascript_driver = :poltergeist

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  else
    # if we're running one file don't join this one
    # as it will get run every time
    Dir[Rails.root.join("spec/models/presenters/*.rb")].each { |f| require f }
  end

  #config.include Devise::TestHelpers

  # TODO: database cleaner
  # TODO: seed concept schemes

  config.before(:each) do
    # clear sidekiq
    Sidekiq::Worker.clear_all

    #Tripod.cache_store.clear!
    #delete everything from fuseki
    Tripod::SparqlClient::Update.update('
      # delete from default graph:
      DELETE {?s ?p ?o} WHERE {?s ?p ?o};
      # delete from named graphs:
      DELETE {graph ?g {?s ?p ?o}} WHERE {graph ?g {?s ?p ?o}};
    ')
  end

  config.after(:each) do
    # clear mongo
    DatabaseCleaner.clean
  end
end
