class Chart
  
  def initialize(event)
    @event = event
    @event_sections = @event.event_sections
    
    initialize_settings
    
    @row_hue = row_hue
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
  
  # Return a hash of arrival sections.
  def arrivals
    return @event_sections[:arrivals]
  end
  
  # Return a hash of departure sections.
  def departures
    return @event_sections[:departures]
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
    
    # Take a date and two times, and return a hash containing a string of the
    # SVG polygon points for a time bar, the left side of the bar, and the
    # right side of the bar.
    def bar_points(this_date, start_time, end_time, row)
    
      points = Array.new
      top = flight_bar_top(row)
      middle = top + @flight_bar_height/2
      bottom = top + @flight_bar_height
    
      # Check if bar starts today or before today
      if start_time.to_date == this_date
        # Draw left bar edge
        left_side = @chart_left + (start_time.hour*@hour_width) + (start_time.min*@hour_width/60)
        points.push("#{left_side},#{bottom}")
        points.push("#{left_side},#{top}")
      elsif start_time.to_date < this_date
        # Draw left arrow edge
        left_side = @chart_left
        points.push("#{left_side},#{bottom}")
        points.push("#{left_side - @flight_bar_arrow_width},#{middle}")
        points.push("#{left_side},#{top}")
      else
        # This bar should not be drawn today
        return nil
      end
    
      # Check if bar ends today or after today
      if end_time.to_date == this_date
        # Draw right bar edge
        right_side = @chart_left + (end_time.hour*@hour_width) + (end_time.min*@hour_width/60)
        points.push("#{right_side},#{top}")
        points.push("#{right_side},#{bottom}")
      elsif end_time.to_date > this_date
        # Draw right arrow edge
        right_side = @chart_right
        points.push("#{right_side},#{top}")
        points.push("#{right_side + @flight_bar_arrow_width},#{middle}")
        points.push("#{right_side},#{bottom}")
      else
        # This bar should not be drawn today
        return nil
      end
    
      return {points: points.join(" "), left: left_side, right: right_side}
    
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
      
    	# Determine number of rows, and create array of key airports so we can identify when airports change:
      person_key_airports = Array.new
    	@event_sections[direction].each do |person|
    		if person_has_flight_on_date?(person, date)
          if direction == :arrivals
            person_key_airports.push(person[:flights].last.arr_airport_iata)
          else
            person_key_airports.push(person[:flights].first.dep_airport_iata)
          end
        end
    	end	  
      number_of_rows = person_key_airports.length
       
      if number_of_rows > 0
        
    		chart_height = @name_height * number_of_rows
    		image_height = @chart_top + chart_height + @image_padding
        
        html += %Q(<h3>#{date.strftime("%A, %B %-d, %Y")}</h3>\n\n)
        
        html += %Q(<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="#{@image_width}" height="#{image_height}">\n)
        
        # Draw background:
        html += %Q(\t<rect width="#{@image_width}" height="#{image_height}" class="svg_background" />\n)
        
        # Draw legend:
        @row_hue.each_with_index do |(airport, hue), index|
          legend_left = @chart_right - ((@row_hue.length - index) * @legend_width)
          text_left = legend_left + (@legend_box_size * 1.25)
          arriving_departing = (direction == :arrivals) ? "Arriving at" : "Departing from"
      		html += %Q(\t<g cursor="default">\n)
          html += %Q(\t\t<title>#{airport}</title>\n)
          html += %Q(\t\t<rect width="#{@legend_box_size}" height="#{@legend_box_size}" x="#{legend_left}" y="#{@image_padding}" fill="hsl(#{hue},#{@saturation},#{@lightness_ff_lt})" fill-opacity="#{@bar_opacity}" stroke="hsl(#{hue},#{@saturation},#{@lightness_stroke})" stroke-opacity="#{@bar_opacity}"/>\n)
          html += %Q(\t\t<text x="#{text_left}" y="#{@image_padding + @legend_box_size*0.75}" text-anchor="start">#{arriving_departing} #{airport}</text>\n)
          html += %Q(\t</g>\n)
        end
        
        # Draw chart grid:
        prior_key_airport = nil
    		for x in 0..number_of_rows
          current_key_airport = person_key_airports[x]
          majmin = current_key_airport == prior_key_airport ? "minor" : "major"
          prior_key_airport = current_key_airport
          html += %Q(\t<line x1="#{@image_padding}" y1="#{@chart_top + x * @name_height}" x2="#{@image_padding + @name_width + 24 * @hour_width}" y2="#{@chart_top + x * @name_height}" class="svg_gridline_#{majmin}_horizontal" />\n) 
    		end
    		for x in 0..24
    			html += %Q(\t<text x="#{@image_padding + @name_width + (x * @hour_width)}" y="#{@chart_top - @time_axis_padding}" text-anchor="middle" class="svg_time_label">#{time_label(x)}</text>\n)
    			html += %Q(\t<line x1="#{@image_padding + @name_width + (x * @hour_width)}" y1="#{@chart_top}" x2="#{@image_padding + @name_width + (x * @hour_width)}" y2="#{@chart_top + chart_height + 1}" class="#{x % 12 == 0 ? 'svg_gridline_major' : 'svg_gridline_minor'}" />\n)
    		end
        
    		# Draw flight bars:
    		row_index = 0;
    		@event_sections[direction].each do |person|
    			# Make sure this person has flights on this date, and if so, draw a row for them:
    			if person_has_flight_on_date?(person, date)
            html += draw_row(person, date, row_index)
    				row_index += 1
          end		
    		end
        
        html += %Q(</svg>\n\n)
        
        return html
      else
        return nil
      end
      
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
    
    # Return the SVG for an individual flight bar.
    # Params:
    # +row+:: Which row the flight bar belongs in (zero-indexed)
    # +hue+:: Hue value for this flight bar
    # +flight+:: Flight object to draw bar for
    # +this_date:: The date of the chart that this row belongs to
    def draw_flight_bar(row, hue, flight, this_date)
  	
      start_time = flight.departure_datetime
    	end_time   = flight.arrival_datetime
  	
      bar_values = bar_points(this_date, start_time, end_time, row)
      return nil if bar_values.nil?
      points     = bar_values[:points]
      left_side  = bar_values[:left]
      right_side = bar_values[:right]
      width      = right_side - left_side
    
      html  = "\t<g id=\"flight#{flight[:id]}\" cursor=\"default\">\n"
    
      # Draw tooltip:
      html += "\t\t<title>"
      html += "#{flight.airline_name} #{flight[:flight_number]} \n"
      html += "#{flight.dep_airport_name} – #{flight.arr_airport_name} \n"
      html += time_range(start_time, end_time, flight[:timezone])
      html += "</title>\n"
    
      # Draw flight bar:
      html += %Q(\t\t<polygon id="flight#{flight[:id]}" points="#{points}" class="svg_bar" fill="hsl(#{hue},#{@saturation},#{@lightness_ff_lt})" stroke="hsl(#{hue},#{@saturation},#{@lightness_stroke})" fill-opacity="#{@bar_opacity}" stroke-opacity="#{@bar_opacity}" />\n)
    
      # Draw flight number:  	
  		if width >= @flight_bar_no_text_width
        if width < @flight_bar_line_break_width
    			html += %Q(\t\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height * 0.41}" class="svg_flight_text" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" fill-opacity="#{@bar_opacity}">#{flight.airline_iata}</text>\n)
    			html += %Q(\t\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height * 0.81}" class="svg_flight_text" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" fill-opacity="#{@bar_opacity}">#{flight[:flight_number]}</text>\n)
    		else
    			html += %Q(\t\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height*0.61}" class="svg_flight_text" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" fill-opacity="#{@bar_opacity}">#{flight.airline_iata} #{flight[:flight_number]}</text>\n)
    		end
      end
      html += "\t</g>\n"
      
      return html
    end
    
    # Return the SVG for an individual layover bar.
    # Params:
    # +row+::      Which row the flight bar belongs in (zero-indexed)
    # +hue+::      Hue value for this flight bar
    # +flight_1+:: The Flight object immediately prior to the layover
    # +flight_2+:: The Flight object immediately after the layover
    # +this_date:: The date of the chart that this row belongs to
    def draw_layover_bar(row, hue, flight_1, flight_2, this_date)
      html = String.new
      
    	start_time = flight_1.arrival_datetime
    	end_time   = flight_2.departure_datetime
    
      bar_values = bar_points(this_date, start_time, end_time, row)
      return nil if bar_values.nil?
      points     = bar_values[:points]
      left_side  = bar_values[:left]
      right_side = bar_values[:right]
      width      = right_side - left_side

      html  += %Q(\t<g cursor="default">\n)
    
      # Draw tooltip:
      html += %Q(\t\t<title>)
      html += %Q(Layover at #{flight_1.arr_airport_name}\n)
      html += time_range(start_time, end_time, flight_1[:timezone])
      html += %Q(</title>\n)
    
      # Draw layover bar:
      html += %Q(\t\t<polygon points="#{points}" class="svg_bar" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" stroke="hsl(#{hue},#{@saturation},#{@lightness_stroke})" fill-opacity="#{@bar_opacity}" stroke-opacity="#{@bar_opacity}" />\n)
	
      # Draw layover airport label:
    	html += %Q(\t\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height*0.61}" class="svg_layover_text" fill="hsl(#{hue},#{@saturation},#{@lightness_ff_lt})" fill-opacity="#{@bar_opacity}">#{flight_1.arr_airport_iata}</text>\n)
  	
      html += %Q(\t</g>\n)
    
    	return html
    end
    
    # Return the SVG for a particular chart row.
    # Params:
    # +person+::    One specific element of an event_section array
    # +date::       The date this row is to be drawn in
    # +row_index+:: Which row the layover bar belongs in (zero-indexed)
    def draw_row(person, date, row_index)
      html = String.new
      hue = @row_hue[person[:key_iata]]
      
      html += %Q(\t<a xlink:href="#s-#{person[:section][:id]}">\n)
    	html += %Q(\t\t<text x="#{@image_padding}" y="#{flight_bar_top(row_index) + (@flight_bar_height * 0.4)}" class="svg_person_name">#{person[:section].traveler_name}</text>\n)
    	html += %Q(\t\t<text x="#{@image_padding}" y="#{flight_bar_top(row_index) + (@flight_bar_height * 0.9)}" class="svg_person_nickname">#{person[:section].traveler_note}</text>\n)
      html += %Q(\t</a>\n)

  	  prev_flight = nil
    	person[:flights].each do |flight|
    		# Draw flights:
        html += draw_flight_bar(row_index, hue, flight, date).to_s
		
    		# Draw layover bars if necessary:
    		unless prev_flight.nil?
    			html += draw_layover_bar(row_index, hue, prev_flight, flight, date).to_s
    		end
    		prev_flight = flight
    	end
      
      # Draw airport codes and times at each end of each flight bar:
      start_time = person[:flights].first.departure_datetime
      end_time   = person[:flights].last.arrival_datetime
      section_left = @name_width + @image_padding + (start_time.hour*@hour_width) + (start_time.min*@hour_width/60) - @airport_margin
      section_right = @name_width + @image_padding + (end_time.hour*@hour_width) + (end_time.min*@hour_width/60) + @airport_margin
      if person[:flights].first.departure_datetime.to_date == date
    		html += %Q(<g cursor="default">\n)
        html += %Q(<title>#{person[:flights].first.dep_airport_name}</title>\n)
        html += %Q(<text x="#{section_left}" y="#{flight_bar_top(row_index) + @flight_bar_height * 0.42}" class="svg_airport_label svg_airport_block_start">#{person[:flights].first.dep_airport_iata}</text>\n)
    		html += %Q(<text x="#{section_left}" y="#{flight_bar_top(row_index) + @flight_bar_height * 0.92}" class="svg_time_label svg_airport_block_start">#{format_time_short(person[:flights].first.departure_datetime)}</text>\n)
        html += %Q(</g>\n)
    	end      
      if person[:flights].last.arrival_datetime.to_date == date
    		html += %Q(<g cursor="default">\n)
        html += %Q(<title>#{person[:flights].last.arr_airport_name}</title>\n)
    		html += %Q(<text x="#{section_right}" y="#{flight_bar_top(row_index) + @flight_bar_height * 0.42}" class="svg_airport_label svg_airport_block_end">#{person[:flights].last.arr_airport_iata}</text>\n)
    		html += %Q(<text x="#{section_right}" y="#{flight_bar_top(row_index) + @flight_bar_height * 0.92}" class="svg_time_label svg_airport_block_end">#{format_time_short(person[:flights].last.arrival_datetime)}</text>\n)
        html += %Q(</g>\n)
    	end
      
      return html
    end
    
    # Take two times, and return a string showing the elapsed time in hours and
    # minutes.
    # Params:
    # +start_time+:: Start time
    # +end_time+:: End time
    def elapsed_time(start_time, end_time)
      diff_hour = ((end_time - start_time) / 3600).to_i
      diff_minute = (((end_time - start_time) / 60) % 60).to_i
      "#{diff_hour}h #{diff_minute}m"
    end
    
    # Return the y position of the top of the flight bar of a given row.
    # Params:
    # +row_number+:: Row number (zero-indexed)
    def flight_bar_top(row_number)
    	return @chart_top + (row_number * @name_height) + @flight_bar_margin
    end
    
    # Return a formatted time string.
    # Params:
    # +time+:: The time to format
    def format_time(time)
      time.strftime("%l:%M%P").strip
    end
    
    # Return a formatted time string.
    # Params:
    # +time+:: The time to format
    def format_time_short(time)
      time.strftime("%l:%M%P").chomp('m')
    end
    
    # Check if a person has flights on a given date (return true or false).
    # Params:
    # +person+:: One specific element of an event_section array.
    # +date+:: The date to check.
    def person_has_flight_on_date?(person, date)
      (person[:flights].any? && person[:flights].first.departure_datetime.to_date <= date && person[:flights].last.arrival_datetime.to_date >= date)
    end
    
    # Return a hash of hues for each key airport, with the airport IATA as key
    # and the hue as value.
    def row_hue
      row_hue = Hash.new
      key_airports = Set.new
    
      [@event_sections[:arrivals], @event_sections[:departures]].each do |section_directions|
        section_directions.each do |section|
          key_airports.add(section[:key_iata])
        end
      end
      key_airports.reject!(&:blank?)
      hue_step = key_airports.length > 0 ? 360/key_airports.length : 0
      key_airports.each_with_index do |airport, index|
        row_hue[airport] = index*hue_step
      end
      
      return row_hue
    end
    
    def time_label(hour)
    	case hour
    	when 0
    		return "mdnt"
    	when 1..11
    		return hour.to_s + "am"
    	when 12
    		return "noon"
    	when 13..23
    		return (hour - 12).to_s + "pm"
    	when 24
    		return "mdnt"
    	end
    end
    
    # Return a string containing a time range and elapsed time.
    # Params:
    # +start_time+:: Start time
    # +end_time+:: End time
    # +timezone+:: String containing the timezone of the direction
    def time_range(start_time, end_time, timezone)
      html = "#{format_time(start_time)} – #{format_time(end_time)} #{timezone} "
      html += "(#{elapsed_time(start_time, end_time)})"
    end
  
end