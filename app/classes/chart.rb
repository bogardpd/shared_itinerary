class Chart
  
  def initialize(event)
    @event = event
    @flight_data_by_date = @event.flight_data_by_date
    @airport_hues = @event.airport_hues
    @airport_names = Airport.airport_names
    
    @timezone = @event.event_timezone
    
    initialize_settings

  end
  
  # Return HTML and SVG code for arrival and departure charts.
  def draw
    html = String.new
    
    html += "<h2>Arriving Flights</h2>\n"
    html += draw_direction_charts(@flight_data_by_date, :arrivals)
    html += "<h2>Departing Flights</h2>\n"
    html += draw_direction_charts(@flight_data_by_date, :departures)
    
    return html.html_safe
  end
  
  # Return the airport color array
  def colors
    airport_colors = Hash.new
    @airport_hues.each do |airport, hue|
      airport_colors.store(airport, {background: "#{hue},#{@saturation},#{@lightness_lf_ft}", border: "#{hue},#{@saturation},#{@lightness_ff_lt}"})
    end
    return airport_colors
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
    # Params:
    # +day_time_range_utc+:: A range of UTC times for the local day this bar is being plotted on
    # +bar_time_range_utc+:: A range of UTC times for the duration of the bar
    # +row+:: Which row the bar belongs in (zero-indexed)
    def bar_points(day_time_range_utc, bar_time_range_utc, row)
      # Ensure ranges overlap:
      return nil unless (day_time_range_utc.begin <= bar_time_range_utc.end && bar_time_range_utc.begin <= day_time_range_utc.end)
      
      points = Array.new
      top = flight_bar_top(row)
      middle = top + @flight_bar_height/2
      bottom = top + @flight_bar_height
            
      # Check if bar starts today or before today
      if day_time_range_utc.include?(bar_time_range_utc.begin)
        # Draw left bar edge
        left_side = x_position_in_local_day(day_time_range_utc, bar_time_range_utc.begin)
        points.push("#{left_side},#{bottom}")
        points.push("#{left_side},#{top}")
      else
        # Draw left arrow edge
        left_side = @chart_left
        points.push("#{left_side},#{bottom}")
        points.push("#{left_side - @flight_bar_arrow_width},#{middle}")
        points.push("#{left_side},#{top}")     
      end

      # Check if bar ends today or after today
      if day_time_range_utc.include?(bar_time_range_utc.end)
        # Draw right bar edge
        right_side = x_position_in_local_day(day_time_range_utc, bar_time_range_utc.end)
        points.push("#{right_side},#{top}")
        points.push("#{right_side},#{bottom}")
      else
        # Draw right arrow edge
        right_side = @chart_right
        points.push("#{right_side},#{top}")
        points.push("#{right_side + @flight_bar_arrow_width},#{middle}")
        points.push("#{right_side},#{bottom}")
      end

      return {points: points.join(" "), left: left_side, right: right_side}
    
    end
    
    # Return a hash of departures and arrivals, with :arrivals or :departures as
    # the keys and ranges of dates as the values.
    # Params:
    # +traveler_array+:: A traveler array for a single direction (arrivals or departures)
    def date_range(traveler_array)
    	date_range = [nil,nil];
	
    	traveler_array.each do |traveler|
    		traveler[:flights].each do |flight|
          origin_date_event      = flight.origin_time.in_time_zone(@timezone).to_date
          destination_date_event = flight.destination_time.in_time_zone(@timezone).to_date
          
          if (date_range[0].nil? || origin_date_event < date_range[0])
    				date_range[0] = origin_date_event
    			end
    			if (date_range[1].nil? || destination_date_event > date_range[1])
    				date_range[1] = destination_date_event
    			end
    		end
    	end
    
      return date_range
    end
    
    # Accept a date and a direction, and return a chart showing all applicable
    # flights and layovers on that date.
    # Params: 
    # +date_local+:: The date to show (in the timezone of the event)
    # +date_local_data+:: A date hash (from Event.flight_data_by_date)
    # +direction+:: Arrivals (:arrivals) or departures (:departures)
    def draw_date_chart(date_local, date_local_data, direction)
      number_of_rows = date_local_data[:travelers].count
      return nil unless number_of_rows > 0
      
      html = String.new
      chart_height = @name_height * number_of_rows
      image_height = @chart_top + chart_height + @image_padding
      
      html += %Q(<h3>#{date_local.strftime("%A, %-d %B %Y")}</h3>\n\n)
      html += %Q(<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="#{@image_width}" height="#{image_height}">\n)
      
      # Draw background:
      html += %Q(\t<rect width="#{@image_width}" height="#{image_height}" class="svg_background" />\n)
      
      # Draw legend:
      @airport_hues.each_with_index do |(airport, hue), index|
        legend_left = @chart_right - ((@airport_hues.length - index) * @legend_width)
        text_left = legend_left + (@legend_box_size * 1.25)
        arriving_departing = (direction == :arrivals) ? "Arriving at" : "Departing from"
        html += %Q(\t<g cursor="default">\n)
        html += %Q(\t\t<title>#{@airport_names[airport] || airport}</title>\n)
        html += %Q(\t\t<rect width="#{@legend_box_size}" height="#{@legend_box_size}" x="#{legend_left}" y="#{@image_padding}" fill="hsl(#{hue},#{@saturation},#{@lightness_ff_lt})" fill-opacity="#{@bar_opacity}" stroke="hsl(#{hue},#{@saturation},#{@lightness_stroke})" stroke-opacity="#{@bar_opacity}"/>\n)
        html += %Q(\t\t<text x="#{text_left}" y="#{@image_padding + @legend_box_size*0.75}" text-anchor="start">#{arriving_departing} #{airport}</text>\n)
        html += %Q(\t</g>\n)
      end
      
      # Draw chart grid:
      key_airports = date_local_data[:travelers].map{|k,v| v[:key_iata]}
      prior_key_airport = nil
      for x in 0..number_of_rows
        current_key_airport = key_airports[x]
        majmin = current_key_airport == prior_key_airport ? "minor" : "major"
        prior_key_airport = current_key_airport
        html += %Q(\t<line x1="#{@image_padding}" y1="#{@chart_top + x * @name_height}" x2="#{@image_padding + @name_width + 24 * @hour_width}" y2="#{@chart_top + x * @name_height}" class="svg_gridline_#{majmin}_horizontal" />\n)
      end
      day_time_range_utc = date_local_data[:start_time_utc]..date_local_data[:end_time_utc]
      # if != 24 hours
      time_at_0000 = Time.find_zone(@timezone).local(date_local.year, date_local.month, date_local.day)
      time_at_2400 = time_at_0000 + 24.hours
      if time_at_0000.gmt_offset == time_at_2400.gmt_offset
        # Show one time label row
        html += %Q(\t<text x="#{@image_padding}" y="#{@chart_top - @time_axis_padding}" text-anchor="left" class="svg_time_label">#{time_at_0000.strftime("(%:z) %Z").downcase}</text>\n)
        for x in 0..24
          html += %Q(\t<text x="#{@image_padding + @name_width + (x * @hour_width)}" y="#{@chart_top - @time_axis_padding}" text-anchor="middle" class="svg_time_label">#{time_label(x)}</text>\n)
          html += %Q(\t<line x1="#{@image_padding + @name_width + (x * @hour_width)}" y1="#{@chart_top}" x2="#{@image_padding + @name_width + (x * @hour_width)}" y2="#{@chart_top + chart_height + 1}" class="#{x % 12 == 0 ? 'svg_gridline_major' : 'svg_gridline_minor'}" />\n)
        end
      else
        # Show two time label rows

      end
      
      # Draw traveler rows:
      date_local_data[:travelers].each_with_index do |(traveler_id, traveler), index|
        html += draw_row(direction, day_time_range_utc, traveler_id, traveler, index)
      end
      
      html += %Q(</svg>\n\n)
      
      return html
      
    end
    
    # Return the HTML and SVG for all flight charts in a given direction.
    # Params:
    # +data_by_date+:: The hash generated by Event.flight_data_by_date
    # +direction+:: Arrivals (:arrivals) or departures (:departures)
    def draw_direction_charts(data_by_date, direction)
      html = String.new
      
      if data_by_date[direction].any?
        data_by_date[direction].each do |date_local, date_local_data|
          html += draw_date_chart(date_local, date_local_data, direction)
        end
      else
        direction_text = direction == :arrivals ? "arriving" : "departing"
        html += "<p>When #{direction_text} flights are added to any traveler, the flights will show up here.</p>\n"
      end
        
      return html
    end
    
    # Return the SVG for an individual flight bar.
    # Params:
    # +day_time_range_utc+:: A range of UTC times for the local day this flight is being plotted on
    # +row+:: Which row the flight bar belongs in (zero-indexed)
    # +hue+:: Hue value for this flight bar
    # +flight+:: Flight data hash to draw bar for
  	def draw_flight_bar(day_time_range_utc, row, hue, flight)
      html = String.new
      
      flight_time_range_utc = flight[:origin_time_utc]..flight[:destination_time_utc]
      flight_time_range_local = flight[:origin_time_utc].in_time_zone(@timezone)..flight[:destination_time_utc].in_time_zone(@timezone)
      
      bar_values = bar_points(day_time_range_utc, flight_time_range_utc, row)
      return nil if bar_values.nil?
      points     = bar_values[:points]
      left_side  = bar_values[:left]
      right_side = bar_values[:right]
      width      = right_side - left_side

      html  = %Q(\t<g id="flight-#{flight[:id]}" cursor="default">\n)

      # Draw tooltip:
      html += "\t\t<title>"
      html += "#{flight[:airline_name]} #{flight[:flight_number]} \n"
      html += "#{flight[:origin_name]} – #{flight[:destination_name]} \n"
      html += time_range(flight_time_range_local, flight_time_range_local.begin.strftime("%Z"))
      html += "</title>\n"

      # Draw flight bar:
      html += %Q(\t\t<polygon id="flight-#{flight[:id]}" points="#{points}" class="svg_bar" fill="hsl(#{hue},#{@saturation},#{@lightness_ff_lt})" stroke="hsl(#{hue},#{@saturation},#{@lightness_stroke})" fill-opacity="#{@bar_opacity}" stroke-opacity="#{@bar_opacity}" />\n)

      # Draw flight number:
      if width >= @flight_bar_no_text_width
        if width < @flight_bar_line_break_width
          html += %Q(\t\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height * 0.41}" class="svg_flight_text" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" fill-opacity="#{@bar_opacity}">#{flight[:airline_iata]}</text>\n)
          html += %Q(\t\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height * 0.81}" class="svg_flight_text" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" fill-opacity="#{@bar_opacity}">#{flight[:flight_number]}</text>\n)
        else
          html += %Q(\t\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height*0.61}" class="svg_flight_text" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" fill-opacity="#{@bar_opacity}">#{flight[:airline_iata]} #{flight[:flight_number]}</text>\n)
        end
      end
      html += "\t</g>\n"
      
      return html
    end
    
    # Return the SVG for an individual layover bar.
    # Params:
    # +day_time_range_utc+:: A range of UTC times for the local day this layover is being plotted on
    # +row+:: Which row the layover bar belongs in (zero-indexed)
    # +hue+:: Hue value for this layover bar
    # +layover+:: Layover data hash to draw bar for
    def draw_layover_bar(day_time_range_utc, row, hue, layover)
      html = String.new
      
      layover_time_range_utc = layover[:start_time_utc]..layover[:end_time_utc]
      layover_time_range_local = layover[:start_time_utc].in_time_zone(@timezone)..layover[:end_time_utc].in_time_zone(@timezone)
      
      bar_values = bar_points(day_time_range_utc, layover_time_range_utc, row)
      return nil if bar_values.nil?
      points     = bar_values[:points]
      left_side  = bar_values[:left]
      right_side = bar_values[:right]
      width      = right_side - left_side
      
      html  += %Q(\t<g cursor="default">\n)

      # Draw tooltip:
      html += %Q(\t\t<title>)
      html += %Q(Layover at #{layover[:start_name]}\n)
      html += time_range(layover_time_range_local, layover_time_range_local.begin.strftime("%Z"))
      html += %Q(</title>\n)

      # Draw layover bar:
      html += %Q(\t\t<polygon points="#{points}" class="svg_bar" fill="hsl(#{hue},#{@saturation},#{@lightness_lf_ft})" stroke="hsl(#{hue},#{@saturation},#{@lightness_stroke})" fill-opacity="#{@bar_opacity}" stroke-opacity="#{@bar_opacity}" />\n)

      # Draw layover airport label:
      if width >= @flight_bar_no_text_width
        html += %Q(\t\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height*0.61}" class="svg_layover_text" fill="hsl(#{hue},#{@saturation},#{@lightness_ff_lt})" fill-opacity="#{@bar_opacity}">#{layover[:start_iata]}</text>\n)
      else
        [0.30,0.61,0.92].each_with_index do |ypos, index|
          html += %Q(\t\t<text x="#{(left_side + right_side) / 2}" y="#{flight_bar_top(row) + @flight_bar_height*ypos}" class="svg_layover_text" fill="hsl(#{hue},#{@saturation},#{@lightness_ff_lt})" fill-opacity="#{@bar_opacity}">#{layover[:start_iata][index]}</text>\n)
        end
      end

      html += %Q(\t</g>\n)
    
    	return html
    end
    
    # Return the SVG for a particular chart row.
    # Params:
    # +direction+:: Arrivals (:arrivals) or departures (:departures)
    # +day_time_range_utc+:: A range of UTC times for the local day this row is being plotted on
    # +traveler_id+:: ID of the traveler being plotted
    # +traveler_data+:: Hash of traveler data
    # +row_index+:: Which row the layover bar belongs in (zero-indexed)
    def draw_row(direction, day_time_range_utc, traveler_id, traveler_data, row_index)
      html = String.new
      
      hue = @airport_hues[traveler_data[:key_iata]]

      html += %Q(\t<a xlink:href="#t-#{traveler_id}">\n)
      html += %Q(\t\t<text x="#{@image_padding}" y="#{flight_bar_top(row_index) + (@flight_bar_height * 0.4)}" class="svg_person_name">#{traveler_data[:name]}</text>\n)
      html += %Q(\t\t<text x="#{@image_padding}" y="#{flight_bar_top(row_index) + (@flight_bar_height * 0.9)}" class="svg_person_nickname">#{traveler_data[:note]}</text>\n)
      html += %Q(\t</a>\n)
      
      # Draw flights:
      traveler_data[:flights].each do |flight|
        html += draw_flight_bar(day_time_range_utc, row_index, hue, flight)
      end
      
      # Draw layovers:
      traveler_data[:layovers].each do |layover|
        html += draw_layover_bar(day_time_range_utc, row_index, hue, layover)
      end

      # Draw airport codes and times at each end of each flight bar:
      
      if direction == :arrivals
        travel_start_time_utc = traveler_data[:alt_time_utc]
        travel_end_time_utc   = traveler_data[:key_time_utc]
      else
        travel_start_time_utc = traveler_data[:key_time_utc]
        travel_end_time_utc   = traveler_data[:alt_time_utc]
      end
      start_x = x_position_in_local_day(day_time_range_utc, travel_start_time_utc)
      end_x   = x_position_in_local_day(day_time_range_utc, travel_end_time_utc)
      if start_x
        html += %Q(<g cursor="default">\n)
        html += %Q(<title>#{traveler_data[:flights].first[:origin_name]}</title>\n)
        html += %Q(<text x="#{start_x - @airport_margin}" y="#{flight_bar_top(row_index) + @flight_bar_height * 0.42}" class="svg_airport_label svg_airport_block_start">#{traveler_data[:flights].first[:origin_iata]}</text>\n)
        html += %Q(<text x="#{start_x - @airport_margin}" y="#{flight_bar_top(row_index) + @flight_bar_height * 0.92}" class="svg_time_label svg_airport_block_start">#{format_time_short(travel_start_time_utc.in_time_zone(@timezone))}</text>\n)
        html += %Q(</g>\n)
      end
      if end_x
        html += %Q(<g cursor="default">\n)
        html += %Q(<title>#{traveler_data[:flights].last[:destination_name]}</title>\n)
        html += %Q(<text x="#{end_x + @airport_margin}" y="#{flight_bar_top(row_index) + @flight_bar_height * 0.42}" class="svg_airport_label svg_airport_block_end">#{traveler_data[:flights].last[:destination_iata]}</text>\n)
        html += %Q(<text x="#{end_x + @airport_margin}" y="#{flight_bar_top(row_index) + @flight_bar_height * 0.92}" class="svg_time_label svg_airport_block_end">#{format_time_short(travel_end_time_utc.in_time_zone(@timezone))}</text>\n)
        html += %Q(</g>\n)
      end
      
      return html
    end
    
    # Take two times, and return a string showing the elapsed time in hours and
    # minutes.
    # Params:
    # +time_range+:: A range of Time objects
    def elapsed_time(time_range)
      diff_hour = ((time_range.end - time_range.begin) / 3600).to_i
      diff_minute = (((time_range.end - time_range.begin) / 60) % 60).to_i
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
    
    # Creates a string for a given hour to label the chart x-axis.
    # Params:
    # +hour+:: The hour to format    
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
    def time_range(time_range_utc, timezone)
      html = "#{format_time(time_range_utc.begin)} – #{format_time(time_range_utc.end)} #{timezone} "
      html += "(#{elapsed_time(time_range_utc)})"
    end
    
    # Return an x position for a UTC time based on a given UTC time range.
    # Params:
    # +day_time_range_utc+:: The UTC range to position the time in
    # +time_utc+:: The UTC time to position in the range
    def x_position_in_local_day(day_time_range_utc, time_utc)
      return nil unless day_time_range_utc.include?(time_utc)
      return ((time_utc - day_time_range_utc.begin) / (day_time_range_utc.end - day_time_range_utc.begin)) * (@chart_right - @chart_left) + @chart_left
    end
  
end