class Chart
  
  def initialize(event)
    @event = event
    @event_sections = event_sections
    initialize_settings
  end
  
  # Return HTML and SVG code for arrival and departure charts.
  def draw
    html = String.new
    
    html += "<h2>Incoming Flights</h2>\n"
    html += draw_direction_charts(@event_sections[:arrivals])
    html += "<h2>Returning Flights</h2>\n"
    html += draw_direction_charts(@event_sections[:departures])
    
    return html.html_safe
  end
  
  private
    
    # Define chart visual settings.
    def initialize_settings
      # Settable colors:
      @lightness_ff_lt             = '40%' # Flight fill, layover text
      @lightness_lf_ft             = '90%' # Layover fill, flight text
      @lightness_stroke            = '30%'
      @saturation                  = '50%'
      @bar_opacity                 = '0.9'
  
      # Settable distances (all values in pixels):
      @image_padding               = 15
                               
      @legend_width                = 140
      @legend_height               = 30
      @legend_box_size             = 16
  
      @time_axis_height            = 20
      @time_axis_padding           = 5
  
      @name_width                  = 130
      @name_height                 = 40
  
      @hour_width                  = 38.5
  
      @flight_bar_height           = 30
      @flight_bar_arrow_width      = 5
      @flight_bar_buffer_width     = 48
      @flight_bar_line_break_width = 50 # If flight bar width is less than this, add a line break
      @flight_bar_no_text_width    = 23 # If flight bar width is less than this, do not display text
  
      @airport_margin              = 3
  
      # Derived:
      @image_width = @name_width + (24*@hour_width) + 2*@image_padding + @time_axis_padding + @flight_bar_buffer_width
      @flight_bar_margin = (@name_height - @flight_bar_height) / 2
  
      @chart_top = @image_padding + @legend_height + @time_axis_height
      @chart_left = @image_padding + @name_width
      @chart_right = @chart_left + (24 * @hour_width)
  
    end
    
    # Return a hash of departures and arrivals, with :arrivals or :departures as
    # the keys and ranges of dates as the values.
    # Params:
    # +section_array+:: A section array for a single direction (arrivals or departures)
    def date_range(section_array)
    	date_range = [nil,nil];
	
    	section_array.each do |section|
    		section[:flights].each do |flight|
          if (date_range[0].nil? || flight.departure_datetime.to_date < date_range[0])
    				date_range[0] = flight.departure_datetime.to_date
    			end
    			if (date_range[1].nil? || flight.arrival_datetime.to_date > date_range[1])
    				date_range[1] = flight.arrival_datetime.to_date
    			end
    		end
    	end
    
      return date_range
    end
    
    # Accept a date and a direction, and return a chart showing all applicable
    # flights and layovers on that date.
    # Params: 
    # +date+:: The date to show (in the timezone of the event)
    # +direction+:: Arrivals (:arrivals) or departures (:departures)
    def draw_date_chart(date, direction)
      html = String.new
      html += "Date #{date}, direction #{direction}<br/>\n"
      return html
    end
    
    # Return the HTML and SVG for all flight charts in a given direction.
    # Params:
    # +section_array+:: A section array for a single direction (arrivals or departures)
    def draw_direction_charts(section_array)
      html = String.new
      dates = date_range(section_array)
      if section_array.any? && dates[0] && dates[1]
        direction = section_array.first[:section].is_arrival? ? :arrivals : :departures
      	for d in dates[0]..dates[1]
          html += draw_date_chart(d, direction)
      	end
      else
        html += "<p>When incoming flights are added, they will show up here.</p>\n"
      end
      return html
    end
  
    # Return a hash of departures and arrivals, with :arrivals or :departures as
    # the keys and arrays of sections as the values.
    def event_sections
      section_hash = Hash.new
      arrivals = Array.new
      departures = Array.new
      @event.sections.each do |section|
        if section.is_arrival?
          flight_list = section.flights.order(:arrival_datetime)
          flight_any = (flight_list.length > 0)
          arrivals.push(  section:     section,
                           flights:     flight_list,
                           key_airport: flight_any ? flight_list.last.arrival_airport : Airport.new,
                           key_iata:    flight_any ? flight_list.last.arr_airport_iata : "",
                           key_time:    flight_any ? flight_list.last.arrival_datetime : nil,
                           alt_time:    flight_any ? flight_list.first.departure_datetime : nil)
        else
          flight_list = section.flights.order(:departure_datetime)
          flight_any = (flight_list.length > 0)
          departures.push(section:     section,
                           flights:     flight_list,
                           key_airport: flight_any ? flight_list.first.departure_airport : Airport.new,
                           key_iata:    flight_any ? flight_list.first.dep_airport_iata : "",
                           key_time:    flight_any ? flight_list.first.departure_datetime : nil,
                           alt_time:    flight_any ? flight_list.last.arrival_datetime : nil)
        end
      end
      arrivals.sort_by!   { |h| [h[:key_iata], h[:key_time], h[:alt_time]] }
      departures.sort_by! { |h| [h[:key_iata], h[:key_time], h[:alt_time]] }
      section_hash[:arrivals]   = arrivals
      section_hash[:departures] = departures
      return section_hash
    end
  
end