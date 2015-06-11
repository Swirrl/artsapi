require 'sidekiq'
require 'sidekiq-status'

class ArtsAPI::SidekiqServerMiddleware
  def call(worker, message, queue)
    # lock the thread, perform DB work, unlock again
    # this is needed because Tripod is not thread-safe
    # and background jobs work in threads
    # this is a coarse locking strategy, you may want to improve
    semaphore = Mutex.new
    semaphore.synchronize do

      # wrapper for a thread local variable
      User.current_user = User.find(message["args"][1]) if message["args"][1]

      yield
    end
  ensure
    User.current_user = nil
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