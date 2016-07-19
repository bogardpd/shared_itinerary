module EventsHelper
  
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
  
  def draw_charts
  	initialize_settings
        
    # Determine earliest and latest dates
  	date_range = [get_date_range(@arrivals), get_date_range(@departures)]
	
    concat "<h2>Incoming Flights</h2>\n".html_safe
	  
    if @arrivals.any? && date_range[0][0] && date_range[0][1]
    	for d in date_range[0][0]..date_range[0][1]
    		draw_date_chart(d, @arrivals, true, @timezones[0])
    	end
    else
      concat "<p>When incoming flights are added, they will show up here.</p>".html_safe
    end
	
  	concat "<h2>Returning Flights</h2>\n".html_safe
	  
    if @departures.any? && date_range[1][0] && date_range[1][1]
    	for d in date_range[1][0]..date_range[1][1]
    		draw_date_chart(d, @departures, false, @timezones[1])
    	end
    else
      concat "<p>When returning flights are added, they will show up here.</p>".html_safe
    end
  end


  def draw_date_chart(date, flight_array, arriving, timezone)
	
  	this_date = date
	
  	# Determine number of rows, and create array of key airports so we can identify when airports change:
  	
    person_key_airports = Array.new
  	flight_array.each do |person|
  		if person_has_flight_on_date?(person, this_date)
        if arriving
          person_key_airports.push(person[:flights].last.arrival_airport_iata)
        else
          person_key_airports.push(person[:flights].first.departure_airport_iata)
        end
      end
  	end	  
    number_of_rows = person_key_airports.length
    
  	if number_of_rows > 0
	
  		chart_height = @name_height * number_of_rows
  		image_height = @chart_top + chart_height + @image_padding
      
      concat "<h3>#{this_date.strftime("%A, %B %-d, %Y")} (#{timezone})</h3>\n".html_safe
      
  		concat "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"#{@image_width}\" height=\"#{image_height}\">\n\n".html_safe
  		concat "<rect width=\"#{@image_width}\" height=\"#{image_height}\" class=\"svg_background\" />\n".html_safe
	    
      # Draw legend:
      
      @row_hue.each_with_index do |(airport, hue), index|
        legend_left = @chart_right - ((@row_hue.length - index) * @legend_width)
        text_left = legend_left + (@legend_box_size * 1.25)
        arriving_departing = arriving ? "Arriving at" : "Departing from"
    		concat "<g cursor=\"default\">\n".html_safe
        concat "<title>#{airport_name(airport)}</title>\n".html_safe
        concat %Q(<rect width="#{@legend_box_size}" height="#{@legend_box_size}" x="#{legend_left}" y="#{@image_padding}" fill="hsl(#{hue},#{@saturation},#{@lightness_ff_lt})" fill-opacity="#{@bar_opacity}" stroke="hsl(#{hue},#{@saturation},#{@lightness_stroke})" stroke-opacity="#{@bar_opacity}"/>\n).html_safe
        concat %Q(<text x="#{text_left}" y="#{@image_padding + @legend_box_size*0.75}" text-anchor="start">#{arriving_departing} #{airport}</text>\n).html_safe
        concat "</g>"
        
      end
      
  		# Draw chart grid:
	    
      prior_key_airport = nil
  		for x in 0..number_of_rows
          current_key_airport = person_key_airports[x]
        majmin = current_key_airport == prior_key_airport ? "minor" : "major"
        prior_key_airport = current_key_airport
        
        concat "<line x1=\"#{@image_padding}\" y1=\"#{@chart_top + x * @name_height}\" x2=\"#{@image_padding + @name_width + 24 * @hour_width}\" y2=\"#{@chart_top + x * @name_height}\" class=\"svg_gridline_#{majmin}_horizontal\" />\n".html_safe 
  		end
      
  		for x in 0..24
  			concat "<text x=\"#{@image_padding + @name_width + (x * @hour_width)}\" y=\"#{@chart_top - @time_axis_padding}\" text-anchor=\"middle\" class=\"svg_time_label\">#{time_label(x)}</text>\n".html_safe
  			concat "<line x1=\"#{@image_padding + @name_width + (x * @hour_width)}\" y1=\"#{@chart_top}\" x2=\"#{@image_padding + @name_width + (x * @hour_width)}\" y2=\"#{@chart_top + chart_height + 1}\" class=\"#{x % 12 == 0 ? 'svg_gridline_major' : 'svg_gridline_minor'}\" />\n".html_safe
  		end
	
  		# Draw flight bars:
  		row_index = 0;
  		flight_array.each do |person|
  			# Make sure this person has flights on this date, and if so, draw a row for them:
  			if person_has_flight_on_date?(person, this_date)	          
          # Get hue:
  				if arriving
  					this_hue = @row_hue[(person[:flights].last.arrival_airport_iata)]
  				else
  					this_hue = @row_hue[(person[:flights].first.departure_airport_iata)]
  				end
		
  				draw_person_row(person, this_date, row_index, this_hue)
  				row_index += 1
        end		
  		end
	
  		concat "</svg>\n".html_safe

  	end
  end
  
  def draw_person_row(person, this_date, row_index, hue)
  	prev_flight = nil
    
    concat "<a xlink:href=\"#s-#{person[:id]}\">".html_safe
  	concat "<text x=\"#{@image_padding}\" y=\"#{flight_bar_top(row_index) + (@flight_bar_height * 0.4)}\" class=\"svg_person_name\">#{person[:section].traveler_name}\n</text>".html_safe
  	concat "<text x=\"#{@image_padding}\" y=\"#{flight_bar_top(row_index) + (@flight_bar_height * 0.9)}\" class=\"svg_person_nickname\">#{person[:section].traveler_note}\n</text>\n".html_safe
    concat "</a>\n".html_safe
	
  	person[:flights].each_with_index do |flight, flight_index|
  		concat draw_flight_bar(row_index, hue, flight, this_date)
		
  		# Draw layover bars if necessary:
  		unless prev_flight.nil?
  			concat draw_layover_bar(row_index, hue, prev_flight, flight, this_date)
  		end
  		prev_flight = flight
  	end
	
  	start_time = person[:flights].first.departure_datetime
  	end_time   = person[:flights].last.arrival_datetime
	
  	section_left = @name_width + @image_padding + (start_time.hour*@hour_width) + (start_time.min*@hour_width/60) - @airport_margin
  	section_right = @name_width + @image_padding + (end_time.hour*@hour_width) + (end_time.min*@hour_width/60) + @airport_margin
	
  	if person[:flights].first.departure_datetime.to_date == this_date
  		concat "<g cursor=\"default\">\n".html_safe
      concat "<title>#{airport_name(person[:flights].first.departure_airport_iata)}</title>\n".html_safe
      concat "<text x=\"#{section_left}\" y=\"#{flight_bar_top(row_index) + @flight_bar_height * 0.42}\" class=\"svg_airport_label svg_airport_block_start\">#{person[:flights].first.departure_airport_iata}</text>\n".html_safe
  		concat "<text x=\"#{section_left}\" y=\"#{flight_bar_top(row_index) + @flight_bar_height * 0.92}\" class=\"svg_time_label svg_airport_block_start\">#{format_time_short(person[:flights].first.departure_datetime)}</text>\n".html_safe
      concat "</g>\n".html_safe
  	end
	
  	if person[:flights].last.arrival_datetime.to_date == this_date
  		concat "<g cursor=\"default\">\n".html_safe
      concat "<title>#{airport_name(person[:flights].last.arrival_airport_iata)}</title>\n".html_safe
  		concat "<text x=\"#{section_right}\" y=\"#{flight_bar_top(row_index) + @flight_bar_height * 0.42}\" class=\"svg_airport_label svg_airport_block_end\">#{person[:flights].last.arrival_airport_iata}</text>\n".html_safe
  		concat "<text x=\"#{section_right}\" y=\"#{flight_bar_top(row_index) + @flight_bar_height * 0.92}\" class=\"svg_time_label svg_airport_block_end\">#{format_time_short(person[:flights].last.arrival_datetime)}</text>\n".html_safe
      concat "</g>\n".html_safe
  	end
	
  end

  def draw_flight_bar(row, hue, flight, this_date)
  	
    start_time = flight.departure_datetime
  	end_time   = flight.arrival_datetime
  	
    bar_values = bar_points(this_date, start_time, end_time, row)
    return nil if bar_values.nil?
    points     = bar_values[:points]
    left_side  = bar_values[:left]
    right_side = bar_values[:right]
    width      = right_side - left_side
    
    html  = "<g id=\"flight#{flight[:id]}\" cursor=\"default\">\n"
    
    # Draw tooltip:
    html += "<title>"
    html += "#{flight.airline_name} #{flight[:flight_number]} \n"
    html += "#{airport_name(flight.departure_airport_iata)} – #{airport_name(flight.arrival_airport_iata)} \n"
    html += time_range(start_time, end_time, flight[:timezone])
    html += "</title>\n"
    
    # Draw flight bar:
    html += %Q(\t<polygon id="flight#{flight[:id]}" points="#{points}" class="svg_bar" fill="hsl(#{hue},#{@saturation},#{@lightness_ff_lt})" stroke="hsl(#{hue},#{@saturation},#{@lightness_stroke})" fill-opacity="#{@bar_opacity}" stroke-opacity="#{@bar_opacity}" />\n)
    
    # Draw flight number:  	
		if width >= @flight_bar_no_text_width
      if width < @flight_bar_line_break_width
  			html += %Q(\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height * 0.41}" class="svg_flight_text" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" fill-opacity="#{@bar_opacity}">#{flight.airline_iata}</text>\n)
  			html += %Q(\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height * 0.81}" class="svg_flight_text" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" fill-opacity="#{@bar_opacity}">#{flight[:flight_number]}</text>\n)
  		else
  			html += %Q(\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height*0.61}" class="svg_flight_text" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" fill-opacity="#{@bar_opacity}">#{flight.airline_iata} #{flight[:flight_number]}</text>\n)
  		end
    end
    html += "</g>\n"
    
    html.html_safe
  end
  
  def draw_layover_bar(row, hue, flight_1, flight_2, this_date)

  	start_time = flight_1.arrival_datetime
  	end_time   = flight_2.departure_datetime
    
    bar_values = bar_points(this_date, start_time, end_time, row)
    return nil if bar_values.nil?
    points     = bar_values[:points]
    left_side  = bar_values[:left]
    right_side = bar_values[:right]
    width      = right_side - left_side

    html  = "<g cursor=\"default\">\t"
    
    # Draw tooltip:
    html += "<title>"
    html += "Layover at #{airport_name(flight_1.arrival_airport_iata)} \n"
    html += time_range(start_time, end_time, flight_1[:timezone])
    html += "</title>\n"
    
    # Draw layover bar:
    html += %Q(\t<polygon points="#{points}" class="svg_bar" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" stroke="hsl(#{hue},#{@saturation},#{@lightness_stroke})" fill-opacity="#{@bar_opacity}" stroke-opacity="#{@bar_opacity}" />\n)
	
    # Draw layover airport label:
  	html += %Q(\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height*0.61}" class="svg_layover_text" fill="hsl(#{hue},#{@saturation},#{@lightness_ff_lt})" fill-opacity="#{@bar_opacity}">#{flight_1.arrival_airport_iata}</text>\n)
  	
    html += "</g>\n"
    
  	html.html_safe
  end

  
  
  # Returns the y position of the top of the flight bar of a given row
  def flight_bar_top(row_number)
  	return @chart_top + (row_number * @name_height) + @flight_bar_margin
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
  
  # Accepts a section array and returns a date range
  def get_date_range(section_array)
  	date_range = [nil,nil];
	
  	section_array.each do |section|
  		section[:flights].each do |flight|
        ## CHECK - these should already be sorted, so just check first departure and last arrival?
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
  
  # Checks if a person has flights on a given date
  def person_has_flight_on_date?(person, this_date)
    (person[:flights].any? && person[:flights].first.departure_datetime.to_date <= this_date && person[:flights].last.arrival_datetime.to_date >= this_date)
  end
  
  # Takes an airport code, and returns the airport name (if available) and code.
  def airport_name(code)
    if @airport_codes && @airport_codes[code]
      "#{@airport_codes[code]} (#{code})"
    else
      code
    end
  end
  
  # Takes a date and two times, and returns a hash containing a string of the SVG polygon points for a time bar, the left side of the bar, and the right side of the bar.
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
  
  # Takes two times, and returns a string showing the elapsed time in hours and minutes.
  def elapsed_time(start_time, end_time)
    diff_hour = ((end_time - start_time) / 3600).to_i
    diff_minute = (((end_time - start_time) / 60) % 60).to_i
    "#{diff_hour}h #{diff_minute}m"
  end
  
  def format_time(time)
      time.strftime("%l:%M%P").strip
  end
    
  def format_time_short(time)
    time.strftime("%l:%M%P").chomp('m')
  end
  
  # Returns a string containing a time range and elapsed time.
  def time_range(start_time, end_time, timezone)
    html = "#{format_time(start_time)} – #{format_time(end_time)} #{timezone} "
    html += "(#{elapsed_time(start_time, end_time)})"
  end
  
  def markdown_text(md_text)
    # Initializes a Markdown parser
    markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
    markdown.render(md_text).html_safe
  end
  
    
end
