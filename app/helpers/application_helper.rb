module ApplicationHelper

  def page_title(title = nil)
    "| #{title}".html_safe if !title.nil?
  end

end
