require 'memoist'
module TripodOverrides

  extend ActiveSupport::Concern
  extend Memoist

  # override to use correct db
  def find(uri, opts={})
    User.current_user.within do
      super(uri, opts)
    end
  end
  memoize :find

end