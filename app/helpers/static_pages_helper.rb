module StaticPagesHelper
  
  def manage_airlines_link
    count = Airline.where(name: nil).count
    if count > 0
      link_to("Manage airlines", airlines_path, class: "admin-attention") + %Q( <span class="unread">#{count}</span>).html_safe
    else
      link_to "Manage airlines", airlines_path
    end
  end
  
  def manage_airports_link
    count = Airport.where(name: nil).count
    if count > 0
      link_to("Manage airports", airports_path, class: "admin-attention") + %Q( <span class="unread">#{count}</span>).html_safe
    else
      link_to "Manage airports", airports_path
    end
  end
  
end
