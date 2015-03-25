module ApplicationHelper

  def page_title(title = nil)
    "| #{title}".html_safe if !title.nil?
  end

  def add_connection_advice?(connections, uri)
    if connections.nil?
      html = "<p id='connections-notice'>"
      html << "<em>There are only a small number of known connections for this person.<br>"
      html << "To recalculate, <a href='#' data-uri='#{uri.to_s}' id='recalculate-connections'>click here</a>"
      html << " then refresh the page in a couple of minutes.</em>"
      html << "</p>"
      html.html_safe
    else
      connections
    end
  end

  def link_with_path_from(uri)
    Presenters::Resource.create_link_from_uri(uri).html_safe
  end

end
