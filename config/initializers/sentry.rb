require 'raven'

if Rails.env.production? && !ENV['SENTRY_KEY'].nil?
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_KEY']
    config.environments = %w(production)
  end
end