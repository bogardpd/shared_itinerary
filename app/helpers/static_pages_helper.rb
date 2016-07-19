module StaticPagesHelper
  
  def manage_airlines_link
    count = Airline.where(name: nil).count
    if count > 0
      link_to("Manage airlines", airlines_path, class: "admin-attention") + %Q( <span class="unread">#{count}</span>).html_safe
    else
      link_to "Manage airlines", airlines_path
    end
  end
  
end
