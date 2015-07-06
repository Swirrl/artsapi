require 'raven'

if Rails.env.production?
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_KEY']
    config.environments = %w(production)
  end
end