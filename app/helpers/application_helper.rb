module ApplicationHelper

  def airline_icon(airline_code, show_blank_icon: true)
    return "" unless airline_code
    icon_path = Airline.icon_path(airline_code)
    if show_blank_icon
      return image_tag(icon_path, class: "icon", onerror: "this.src='#{ExternalImage::ROOT_PATH}/flights/airline-icons/unknown-airline.png';this.onerror='';").html_safe
    else
      return image_tag(icon_path, class: "icon", onerror: "this.style.display='none';this.onerror='';").html_safe
    end
  end
  
  def admin_link
    count = Airline.where(name: nil).count + Airport.where(needs_review: true).count
    if count > 0
      link_to(%Q(Admin <span class="badge badge-warning">#{count}</span>).html_safe, admin_path, class: "nav-link")
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
      "<meta name=\"description\" content=\"#{page_meta_description}\" />".html_safe
    end
  end
  
  def octicon(icon)
    return image_tag("octicons/#{icon}.svg", class: "octicon")
  end
  
  def tr_open_needs_review(needs_review)
    return "<tr>".html_safe unless needs_review
    return %Q(<tr class="table-warning">).html_safe
  end
  
  def short_date_range(range)
    return "No flights" if range.nil?
    return %Q(<span class="light">from</span> #{short_date(range.begin)}<br/><span class="light">to</span> #{short_date(range.end)}).html_safe
  end
  
  def short_date(dt)
    dt.strftime("%a %-d %b %Y")
  end
  
  def short_datetime(dt)
    dt.strftime("%a %-d %b %H:%M")
  end
  
  def short_time(dt)
    dt.strftime("%H:%M")
  end
  

end