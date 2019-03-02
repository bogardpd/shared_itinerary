module ApplicationHelper

  def airline_icon(icao_code, show_blank_icon: true)
    return "" unless icao_code
    icon_path = Airline.icon_path(icao_code)
    if show_blank_icon
      return image_tag(icon_path, class: "icon", onerror: "this.src='#{ExternalImage::ROOT_PATH}/flights/airline-icons/icao/unknown-airline.png';this.onerror='';")
    else
      return image_tag(icon_path, class: "icon", onerror: "this.style.display='none';this.onerror='';")
    end
  end
  
  def admin_link
    count = Airline.where(name: nil).count + Airport.where(needs_review: true).count
    if count > 0
      link_to(ActiveSupport::SafeBuffer.new + "Admin " + content_tag(:span, count, class: %w(badge badge-warning)), admin_path, class: "nav-link")
    else
      link_to "Admin", admin_path, class: "nav-link"
    end
  end

  # Returns the full title on a per-page basis
  def full_title(page_title = '')
    base_title = "Shared Itinerary"
    if page_title.empty?
      base_title
    else
      page_title + " - " + base_title
    end
  end
  
  # Returns the meta description on a per-page basis.
  def meta_description(page_meta_description = '')
    if page_meta_description.empty?
      ""
    else
      content_tag(:meta, nil, name: "description", content: page_meta_description)
    end
  end
  
  def octicon(icon)
    return image_tag("octicons/#{icon}.svg", class: "octicon")
  end

  def tr_class_needs_review(needs_review)
    return needs_review ? "table-warning" : ""
  end
  
  def short_date_range(range)
    return "No flights" if range.nil?
    
    html = ActiveSupport::SafeBuffer.new
    html += content_tag(:div) do
      concat(content_tag(:span, "from", class: "light"))
      concat(" ")
      concat(sanitize(short_date_nonbreaking(range.begin)))
    end
    html += content_tag(:div) do
      concat(content_tag(:span, "to", class: "light"))
      concat(" ")
      concat(sanitize(short_date_nonbreaking(range.end)))
    end
    return html

  end
  
  def short_date(dt)
    dt.strftime("%a %-d %b %Y")
  end

  def short_date_nonbreaking(dt)
    dt.strftime("%a %-d&nbsp;%b&nbsp;%Y")
  end
  
  def short_datetime(dt)
    dt.strftime("%a %-d %b %H:%M")
  end
  
  def short_time(dt)
    dt.strftime("%H:%M")
  end
  

end