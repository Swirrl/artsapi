require 'sidekiq/api'

class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # removed registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  # ArtsAPI fields
  field :name, type: String
  field :ds_name_slug, type: String
  field :dropbox_auth_token, type: String, default: nil
  field :dropbox_auth_secret, type: String, default: nil
  #field :dropbox_session, type: String

  # background jobs
  field :job_ids, type: Array, default: []
  field :uploads_in_progress, type: Integer, default: 0

  def active_jobs
    # THIS IS WRONG!!
    raise StandardError
    sidekiq_queue = Sidekiq::Queue.new

    current_jobs = self.job_ids
    sidekiq_jids = sidekiq_queue.map(&:jid)

    Rails.logger.debug "> Sidekiq jids: #{sidekiq_jids.inspect}"

    active = current_jobs.map { |job| job if sidekiq_jids.include?(job) }.compact

    self.job_ids = active
    self.save

    active
  end

  def increment_uploads_in_progress!
    self.uploads_in_progress = self.uploads_in_progress + 1
    self.save
  end

  def decrement_uploads_in_progress!
    self.uploads_in_progress = self.uploads_in_progress - 1
    self.save
  end

  # We want to be able to do current_user.within {} to issue DB queries
  def within(&block)
    return unless block_given?
    set_tripod_endpoints!

    yield
  end

  def set_tripod_endpoints!
    name_slug = self.ds_name_slug # dataset name in the fuseki config

    if Rails.env.production?
      Tripod.query_endpoint = "http://#{ENV['ARTSAPI_FUSEKI_PORT_3030_TCP_ADDR']}:3030/#{name_slug}/sparql"
      Tripod.update_endpoint = "http://#{ENV['ARTSAPI_FUSEKI_PORT_3030_TCP_ADDR']}:3030/#{name_slug}/update"
    else
      Tripod.query_endpoint = "http://localhost:3030/#{name_slug}/sparql"
      Tripod.update_endpoint = "http://localhost:3030/#{name_slug}/update"
    end
  end

  class << self

    # Make mongoid and mongo play nice
    def serialize_from_session(key, salt)
      record = to_adapter.get(key[0]["$oid"])
      record if record && record.authenticatable_salt == salt
    end

    # We need to be able to call User.current_user
    # so that we can call the .within {} method above
    # this looks terrifying, but it's an rbates special
    def current_user=(user)
      Thread.current[:current_user] = user
    end

    def current_user
      Thread.current[:current_user]
    end

    def add_job_for_current_user(job_id)
      user = Thread.current[:current_user]
      user.job_ids << job_id
      user.save
    end

  end

end
