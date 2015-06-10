require 'sidekiq'
require 'sidekiq-status'

class ArtsAPI::SidekiqServerMiddleware
  def call(worker, message, queue)
    Rails.logger.debug "SANDWICH\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nUID:#{message["args"][1]}\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    message["args"][1]
    Thread.current[:__session_user__] = User.find(message["args"][1]) if message["args"][1]
    yield
  ensure
    Thread.current[:__session_user__] = nil
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
    chain.add ArtsAPI::SidekiqServerMiddleware
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end