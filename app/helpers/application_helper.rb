module ApplicationHelper

  def page_title(title = nil)
    "| #{title}".html_safe if !title.nil?
  end

  def inline_edit_link_for(uri, opts={})
    small = opts.fetch(:small, false)
    output = "<a href='#' data-uri='#{uri}' class='edit-label #{'small-edit-link' if small}'>"
    output << "<small>" if small
    output << "[edit]"
    output << "</small>" if small
    output << "</a>"
    output.html_safe
  end

  def flash_style_for(key)
    case key.to_s
    when 'alert'
      key = 'warning'
    when 'notice'
      key = 'info'
    else
      key = key.to_s
    end

    key
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

  def link_with_path_from(uri, opts={})
    Presenters::Resource.create_link_from_uri(uri, opts).html_safe
  end

  def process_data_button
    job_count = current_user.active_jobs.count
    upload_count = current_user.uploads_in_progress
    total_count = (job_count + upload_count) || 0

    last_click = current_user.last_clicked_process_data_button || (DateTime.now - 2.days)
    has_clicked_within_24_hrs = !!(DateTime.now < (last_click + 24.hours))

    if total_count > 0 || has_clicked_within_24_hrs
      button_to 'Data processing, please come back later', '#', disabled: true, class: 'btn btn-success process-all-button disabled'
    else
      button_to 'Process uploaded data', process_data_path, remote: true, data: { disable_with: "Processing...", confirm: "Are you sure all data imports have finished?" }, class: 'btn btn-success process-all-button'
    end
  end

end
