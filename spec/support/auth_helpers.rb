module AuthHelpers
  def self.sign_in(user)
    login_as(user, :scope => :user)
  end
end