module ApplicationHelper

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
  
  def flight_times(dep, arr)
    html = short_datetime(dep)
    html+= " &ndash; "
    if Time.at(dep).utc.to_date === Time.at(arr).utc.to_date
      html += short_time(arr)
    else 
      html += short_datetime(arr)
    end
    html.html_safe
  end
  
  def admin_link
    count = Airline.where(name: nil).count + Airport.where(name: nil).count
    if count > 0
      link_to(%Q(Admin <span class="unread">#{count}</span>).html_safe, admin_path, class: "admin-attention")
    else
      link_to "Admin", admin_path
    end
  end

end