module EventsHelper
  
  def markdown_text(md_text)
    # Initializes a Markdown parser
    markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
    sanitize(markdown.render(md_text))
  end
  
  def highlight(hsl_colors)
    return "" if hsl_colors.nil?
    return sanitize(%Q( style="background-color: hsl(#{hsl_colors[:background]});"))
  end
  
  def traveler_direction_title(direction, event_name)
    html = ActiveSupport::SafeBuffer.new
    if direction == :arrivals
      html += "Arrival "
      html += content_tag(:small, "at " + event_name)
    else
      html += "Departure "
      html += content_tag(:small, "from " + event_name)
    end
    return html
  end

  def sort_button(text)
    if (params[:travelersort].nil? && text == "Name") || (params[:travelersort].present? && params[:travelersort].downcase == text.downcase)
      classes = "btn btn-secondary active"
    else
      classes = "btn btn-outline-secondary"
    end
    return link_to("Sort by #{text}", params.permit(:share_link, :travelersort, :anchor).merge(travelersort: text.downcase, anchor: "travelers"), class: classes)
  end

  # Take two times, and return a string showing the elapsed time in hours and
    # minutes.
    # Params:
    # +time_range+:: A range of Time objects
    def elapsed_time(time_range)
      diff_hour = ((time_range.end - time_range.begin) / 3600).to_i
      diff_minute = (((time_range.end - time_range.begin) / 60) % 60).to_i
      "#{diff_hour}h #{diff_minute}m"
    end
  
end