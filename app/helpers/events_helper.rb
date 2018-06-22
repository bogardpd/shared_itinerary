module EventsHelper
  
  def markdown_text(md_text)
    # Initializes a Markdown parser
    markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
    markdown.render(md_text).html_safe
  end
  
  def highlight(hsl_colors)
    return "" if hsl_colors.nil?
    return %Q( style="background-color: hsl(#{hsl_colors[:background]});").html_safe
  end
  
  def traveler_direction_title(direction, event_name)
    html = direction == :arrivals ? "Arrival <small>at #{event_name}</small>" : "Departure <small>from #{event_name}</small>"
    return html.html_safe
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