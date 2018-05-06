module ApplicationHelper

  def airline_icon(airline_iata, show_blank_icon: true)
    icon_path = Airline.icon_path(airline_iata)
    if icon_path
      return image_tag(icon_path, class: "icon")
    elsif show_blank_icon
      blank_path = "#{ExternalImage::ROOT_PATH}/flights/airline-icons/unknown-airline.png"
      return image_tag(blank_path, class: "icon")
    else
      return ""
    end    
  end
  
  def admin_link
    count = Airline.where(name: nil).count + Airport.where(name: nil).count
    if count > 0
      link_to(%Q(Admin <span class="unread">#{count}</span>).html_safe, admin_path, class: "admin-attention")
    else
      link_to "Admin", admin_path
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
  
  def short_datetime(dt)
    dt.strftime("%a %b %-d %H:%M")
  end
  
  def short_time(dt)
    dt.strftime("%H:%M")
  end
  
  

end