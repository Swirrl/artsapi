class ResourceWithPresenter

  attr_accessor :resource_presenter, :presenter_type

  def presenter
    self.resource_presenter.nil? ? self.initialize_presenter : self.resource_presenter 
  end

  def presenter=(presenter_object)
    self.resource_presenter = presenter_object
  end

  # override in models by specifying a :presenter_type
  def initialize_presenter
    presenter_object = presenter_type.nil? ? Presenters::Resource.new(self) : presenter_type.send(:new, self)
    self.resource_presenter = presenter_object
  end

end