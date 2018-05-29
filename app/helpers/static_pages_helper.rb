module StaticPagesHelper
  
  def manage_airlines_link
    count = Airline.where(name: nil).count
    if count > 0
      link_to(%Q(Manage airlines <span class="badge badge-light">#{count}</span>).html_safe, airlines_path, class: "btn btn-warning")
    else
      link_to("Manage airlines", airlines_path, class: "btn btn-outline-primary")
    end
  end
  
  def manage_airports_link
    count = Airport.where(needs_review: true).count
    if count > 0
      link_to(%Q(Manage airports <span class="badge badge-light">#{count}</span>).html_safe, airports_path, class: "btn btn-warning")
    else
      link_to("Manage airports", airports_path, class: "btn btn-outline-primary")
    end
  end
  
end
