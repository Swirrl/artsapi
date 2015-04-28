class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time


  # ArtsAPI fields
  field :name, type: String
  field :ds_name_slug, type: String

  # we want to be able to do current_user.within {} to issue DB queries
  def within(&block)
    return unless block_given?
    set_tripod_endpoints

    yield
  end

  def set_tripod_endpoints
    name_slug = self.ds_name_slug # dataset name in the fuseki config
    Tripod.query_endpoint = "http://#{ENV['ARTSAPI_FUSEKI_PORT_3030_TCP_ADDR']}:3030/#{name_slug}/sparql"
    Tripod.update_endpoint = "http://#{ENV['ARTSAPI_FUSEKI_PORT_3030_TCP_ADDR']}:3030/#{name_slug}/update"
  end

  class << self

    # make mongoid and mongo play nice
    def serialize_from_session(key, salt)
      record = to_adapter.get(key[0]["$oid"])
      record if record && record.authenticatable_salt == salt
    end

    # we need to be able to call User.current_user
    # so that we can call the .within {} method above
    # this looks terrifying, but it's an rbates special
    def current_user=(user)
      Thread.current[:current_user] = user
    end

    def current_user
      Thread.current[:current_user]
    end

  end

end
