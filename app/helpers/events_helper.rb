module EventsHelper
  
  def markdown_text(md_text)
    # Initializes a Markdown parser
    markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
    markdown.render(md_text).html_safe
  end
  
  def initialize_settings
    # Settable colors:
    @lightness_ff_lt = '40%' # Flight fill, layover text
    @lightness_lf_ft = '90%' # Layover fill, flight text
    @lightness_stroke = '30%'
    @saturation = '50%'
    
    # Settable distances (all values in pixels):
    @airport_padding = 3
    @airport_right_buffer = 48
    @arrow_point_length = 5
    @flight_bar_height = 30
    @flight_bar_spacing = 5
    @flight_bar_line_break_width = 50 # If flight bar width is less than this, add a line break
    @flight_bar_no_text_width = 23 # If flight bar width is less than this, do not display text
    @image_padding = 15
    @name_width = 130
    @pixels_per_hour = 38.5
    @time_label_padding = 5
    
    # Derived:
    @image_width = @name_width + (24*@pixels_per_hour) + 2*@image_padding + @time_label_padding + @airport_right_buffer
    @chart_top = @image_padding + @time_label_padding
    @chart_left = @image_padding + @name_width
    @chart_right = @chart_left + (24 * @pixels_per_hour)
    
  end
  
  def draw_charts
  	initialize_settings
        
    # Determine earliest and latest dates
  	date_range = [get_date_range(@flights[0]), get_date_range(@flights[1])]
	
    concat "<h2>Incoming Flights</h2>\n".html_safe
	  
    if @flights[0].any? && date_range[0][0] && date_range[0][1]
    	for d in date_range[0][0]..date_range[0][1]
    		draw_date_chart(d, @flights[0], true, @timezones[0])
    	end
    else
      concat "<p>When incoming flights are added, they will show up here.</p>".html_safe
    end
	
  	concat "<h2>Returning Flights</h2>\n".html_safe
	  
    if @flights[1].any? && date_range[1][0] && date_range[1][1]
    	for d in date_range[1][0]..date_range[1][1]
    		draw_date_chart(d, @flights[1], false, @timezones[1])
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
  		#number_of_rows += 1 if person_has_flight_on_date?(person, this_date)
      if person_has_flight_on_date?(person, this_date)
        if arriving
          person_key_airports.push((person[:flights].last)[:arrival_airport])
        else
          person_key_airports.push((person[:flights].first)[:departure_airport])
        end
      end
  	end	  
    number_of_rows = person_key_airports.length
    
  	if number_of_rows > 0
	
  		chart_height = (@flight_bar_height + 2 * @flight_bar_spacing) * number_of_rows
  		image_height = @chart_top + chart_height + @image_padding
      
      concat "<h3>#{this_date.strftime("%A, %B %-d, %Y")} (#{timezone})</h3>\n".html_safe
      
  		concat "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"#{@image_width}\" height=\"#{image_height}\">\n\n".html_safe
  		concat "<rect width=\"#{@image_width}\" height=\"#{image_height}\" class=\"svg_background\" />\n".html_safe
	
  		# Draw chart grid:
	    
      prior_key_airport = nil
  		for x in 0..number_of_rows
  			#majmin = x == 0 ? "major" : "minor"
          current_key_airport = person_key_airports[x]
        majmin = current_key_airport == prior_key_airport ? "minor" : "major"
        prior_key_airport = current_key_airport
        
        concat "<line x1=\"#{@image_padding}\" y1=\"#{@chart_top + x * (@flight_bar_height + @flight_bar_spacing * 2)}\" x2=\"#{@image_padding + @name_width + 24 * @pixels_per_hour}\" y2=\"#{@chart_top + x * (@flight_bar_height + @flight_bar_spacing * 2)}\" class=\"svg_gridline_#{majmin}_horizontal\" />\n".html_safe 
  		end
      
  		for x in 0..24
  			concat "<text x=\"#{@image_padding + @name_width + (x * @pixels_per_hour)}\" y=\"#{@chart_top - @time_label_padding}\" text-anchor=\"middle\" class=\"svg_time_label\">#{time_label(x)}</text>\n".html_safe
  			concat "<line x1=\"#{@image_padding + @name_width + (x * @pixels_per_hour)}\" y1=\"#{@chart_top}\" x2=\"#{@image_padding + @name_width + (x * @pixels_per_hour)}\" y2=\"#{@chart_top + chart_height + 1}\" class=\"#{x % 12 == 0 ? 'svg_gridline_major' : 'svg_gridline_minor'}\" />\n".html_safe
  		end
	
  		# Draw flight bars:
  		row_index = 0;
  		flight_array.each do |person|
  			# Make sure this person has flights on this date, and if so, draw a row for them:
  			if person_has_flight_on_date?(person, this_date)	          
          # Get hue:
  				if arriving
  					this_hue = @row_hue[((person[:flights].last)[:arrival_airport])]
  				else
  					this_hue = @row_hue[((person[:flights].first)[:departure_airport])]
  				end
		
  				draw_person_row(person, this_date, row_index, this_hue)
  				row_index += 1
        end		
  		end
	
  		concat "</svg>\n".html_safe

  	end
  end

  def draw_flight_bar(row, hue, flight, this_date)
  	start_time = flight[:departure_time]
  	end_time = flight[:arrival_time]
  	left_side = @name_width + @image_padding + (start_time.hour*@pixels_per_hour) + (start_time.min*@pixels_per_hour/60)
  	right_side = @name_width + @image_padding + (end_time.hour*@pixels_per_hour) + (end_time.min*@pixels_per_hour/60)
  	width = right_side - left_side
    time_diff = Hash.new
    time_diff[:minute] = (((flight[:arrival_time]-flight[:departure_time]) / 60) % 60).to_i
    time_diff[:hour] = ((flight[:arrival_time]-flight[:departure_time]) / 3600).to_i
		
    html = "<g id=\"flight#{flight[:id]}\" cursor=\"default\">\n"
    
    html += "<title>"
    html += "#{airline_name(flight[:airline])} #{flight[:flight_number]} \n"
    html += "#{airport_name(flight[:departure_airport])} – #{airport_name(flight[:arrival_airport])} \n"
    html += time_range(start_time, end_time, flight[:timezone])
    html += "</title>\n"
    
  	if flight[:departure_time].to_date == this_date && flight[:arrival_time].to_date == this_date
  		# Flight starts and ends today
      html += "\t<rect x=\"#{left_side}\" y=\"#{row_top(row)}\" width=\"#{width}\" height=\"#{@flight_bar_height}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_ff_lt})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"

  	elsif flight[:departure_time].to_date == this_date && flight[:arrival_time].to_date > this_date
  		# Flight starts today and ends after today
  		html += "\t<polygon id=\"flight#{flight[:id]}\" points=\"#{left_side},#{row_top(row)} #{@chart_right},#{row_top(row)} #{@chart_right + @arrow_point_length},#{row_top(row) + @flight_bar_height/2} #{@chart_right},#{row_top(row) + @flight_bar_height} #{left_side},#{row_top(row) + @flight_bar_height}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_ff_lt})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  		right_side = @chart_right
  		width = right_side - left_side
  	elsif flight[:departure_time].to_date < this_date && flight[:arrival_time].to_date == this_date
  		# Flight starts before today and ends today
  		html += "\t<polygon id=\"flight#{flight[:id]}\" points=\"#{@chart_left},#{row_top(row)} #{right_side},#{row_top(row)} #{right_side},#{row_top(row) + @flight_bar_height} #{@chart_left},#{row_top(row) + @flight_bar_height} #{@chart_left - @arrow_point_length},#{row_top(row) + @flight_bar_height/2}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_ff_lt})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  		left_side = @chart_left
  		width = right_side - left_side
    elsif flight[:departure_time].to_date < this_date && flight[:arrival_time].to_date > this_date
      # Flight starts before today and ends after today
      html += "\t<polygon id=\"flight#{flight[:id]}\" points=\"#{@chart_left},#{row_top(row)} #{@chart_right},#{row_top(row)} #{@chart_right + @arrow_point_length},#{row_top(row) + @flight_bar_height/2} #{@chart_right},#{row_top(row) + @flight_bar_height} #{@chart_left},#{row_top(row) + @flight_bar_height} #{@chart_left - @arrow_point_length},#{row_top(row) + @flight_bar_height/2}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_ff_lt})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  		left_side = @chart_left
      right_side = @chart_right
  		width = right_side - left_side
    else
      # Flight does not overlap today; do not draw flight bar
      return false
  	end
    
    # Draw flight numbers:  	
		if width >= @flight_bar_no_text_width
      if width < @flight_bar_line_break_width
  			html += "\t<text x=\"#{(left_side + right_side) / 2}\" y=\"#{row_top(row) + @flight_bar_height * 0.41}\" class=\"svg_flight_text\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\">#{flight[:airline]}</text>\n"
  			html += "\t<text x=\"#{(left_side + right_side) / 2}\" y=\"#{row_top(row) + @flight_bar_height * 0.81}\" class=\"svg_flight_text\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\">#{flight[:flight_number]}</text>\n"
  		else
  			html += "\t<text x=\"#{(left_side + right_side) / 2}\" y=\"#{row_top(row) + @flight_bar_height*0.61}\" class=\"svg_flight_text\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\">#{flight[:airline]} #{flight[:flight_number]}</text>\n"
  		end
    end
    html += "</g>\n"
    
    html.html_safe
  end
  
  def draw_layover_bar(row, hue, flight_1, flight_2, this_date)

  	start_date = (flight_1[:arrival_time]).to_date
  	end_date = (flight_2[:departure_time]).to_date
  	start_time = flight_1[:arrival_time]
  	end_time = flight_2[:departure_time]
		
  	left_side = @name_width + @image_padding + (start_time.hour*@pixels_per_hour) + (start_time.min*@pixels_per_hour/60)
  	right_side = @name_width + @image_padding + (end_time.hour*@pixels_per_hour) + (end_time.min*@pixels_per_hour/60)
  	width = right_side - left_side
	  
    html = "<g cursor=\"default\">\t"
    
    html += "<title>"
    html += "Layover at #{airport_name(flight_1[:arrival_airport])} \n"
    html += time_range(start_time, end_time, flight_1[:timezone])
    html += "</title>\n"
    
    
    
  	if start_date == this_date && end_date == this_date
  		# Layover starts and ends today
  		html += "\t<rect x=\"#{left_side}\" y=\"#{row_top(row)}\" width=\"#{width}\" height=\"#{@flight_bar_height}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\"  stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  	elsif start_date == this_date && end_date > this_date
  		# Layover starts today and ends after today
  		html += "\t<polygon points=\"#{left_side},#{row_top(row)} #{@chart_right},#{row_top(row)} #{@chart_right + @arrow_point_length},#{row_top(row) + @flight_bar_height/2} #{@chart_right},#{row_top(row) + @flight_bar_height} #{left_side},#{row_top(row) + @flight_bar_height}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  		right_side = @chart_right
  		width = right_side - left_side
  	elsif start_date < this_date && end_date == this_date
  		# Layover starts before today and ends today
  		html += "\t<polygon points=\"#{@chart_left},#{row_top(row)} #{right_side},#{row_top(row)} #{right_side},#{row_top(row) + @flight_bar_height} #{@chart_left},#{row_top(row) + @flight_bar_height} #{@chart_left - @arrow_point_length},#{row_top(row) + @flight_bar_height/2}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  		left_side = @chart_left
  		width = right_side - left_side
  	elsif start_date < this_date && end_date > this_date
      # Layover starts before today and ends after today
  		html += "\t<polygon points=\"#{@chart_left},#{row_top(row)} #{@chart_right},#{row_top(row)} #{@chart_right + @arrow_point_length},#{row_top(row) + @flight_bar_height/2} #{@chart_right},#{row_top(row) + @flight_bar_height} #{@chart_left},#{row_top(row) + @flight_bar_height} #{@chart_left - @arrow_point_length},#{row_top(row) + @flight_bar_height/2}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  		left_side = @chart_left
      right_side = @chart_right
  		width = right_side - left_side
    else
      # Layover does not overlap today; do not draw layover bar
      return false
  	end
	
  	html += "\t<text x=\"#{(left_side + right_side) / 2}\" y=\"#{row_top(row) + @flight_bar_height*0.61}\" class=\"svg_layover_text\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_ff_lt})\">#{flight_1[:arrival_airport]}</text>\n"
  	
    html += "</g>\n"
    
  	html.html_safe
  end

  def draw_person_row(person, this_date, row_index, hue)
  	prev_flight = nil
    
    concat "<a xlink:href=\"#s-#{person[:id]}\">".html_safe
  	concat "<text x=\"#{@image_padding}\" y=\"#{row_top(row_index) + (@flight_bar_height * 0.4)}\" class=\"svg_person_name\">#{person[:name]}\n</text>".html_safe
  	concat "<text x=\"#{@image_padding}\" y=\"#{row_top(row_index) + (@flight_bar_height * 0.9)}\" class=\"svg_person_nickname\">#{person[:note]}\n</text>\n".html_safe
    concat "</a>\n".html_safe
	
  	person[:flights].each_with_index do |flight, flight_index|
  		concat draw_flight_bar(row_index, hue, flight, this_date)
		
  		# Draw layover bars if necessary:
  		unless prev_flight.nil?
  			concat draw_layover_bar(row_index, hue, prev_flight, flight, this_date)
  		end
  		prev_flight = flight
  	end
	
  	start_time = (person[:flights].first)[:departure_time]
  	end_time = (person[:flights].last)[:arrival_time]
	
  	section_left = @name_width + @image_padding + (start_time.hour*@pixels_per_hour) + (start_time.min*@pixels_per_hour/60) - @airport_padding
  	section_right = @name_width + @image_padding + (end_time.hour*@pixels_per_hour) + (end_time.min*@pixels_per_hour/60) + @airport_padding
	
  	if person[:flights].first[:departure_time].to_date == this_date
  		concat "<g cursor=\"default\">\n".html_safe
      concat "<title>#{airport_name(person[:flights].first[:departure_airport])}</title>\n".html_safe
      concat "<text x=\"#{section_left}\" y=\"#{row_top(row_index) + @flight_bar_height * 0.42}\" class=\"svg_airport_label svg_airport_block_start\">#{person[:flights].first[:departure_airport]}</text>\n".html_safe
  		concat "<text x=\"#{section_left}\" y=\"#{row_top(row_index) + @flight_bar_height * 0.92}\" class=\"svg_time_label svg_airport_block_start\">#{format_time_short(person[:flights].first[:departure_time])}</text>\n".html_safe
      concat "</g>\n".html_safe
  	end
	
  	if person[:flights].last[:arrival_time].to_date == this_date
  		concat "<g cursor=\"default\">\n".html_safe
      concat "<title>#{airport_name(person[:flights].last[:arrival_airport])}</title>\n".html_safe
  		concat "<text x=\"#{section_right}\" y=\"#{row_top(row_index) + @flight_bar_height * 0.42}\" class=\"svg_airport_label svg_airport_block_end\">#{person[:flights].last[:arrival_airport]}</text>\n".html_safe
  		concat "<text x=\"#{section_right}\" y=\"#{row_top(row_index) + @flight_bar_height * 0.92}\" class=\"svg_time_label svg_airport_block_end\">#{format_time_short(person[:flights].last[:arrival_time])}</text>\n".html_safe
      concat "</g>\n".html_safe
  	end
	
  end

  def row_top(row_number)
  	return (@chart_top + @flight_bar_spacing + (row_number * (2 * @flight_bar_spacing + @flight_bar_height)))
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
  
  # Accepts a flight array and returns a date range
  def get_date_range(flight_array)
  	date_range = [nil,nil];
	
  	flight_array.each do |person|
  		person[:flights].each do |flight|
  			if (date_range[0].nil? || flight[:departure_time].to_date < date_range[0])
  				date_range[0] = flight[:departure_time].to_date
  			end
  			if (date_range[1].nil? || flight[:arrival_time].to_date > date_range[1])
  				date_range[1] = flight[:arrival_time].to_date
  			end
  		end
  	end
    
    return date_range
  end
  
  # Checks if a person has flights on a given date
  def person_has_flight_on_date?(person, this_date)
    (person[:flights].any? && (person[:flights].first)[:departure_time].to_date <= this_date && (person[:flights].last)[:arrival_time].to_date >= this_date)
  end
  
  # Takes an airline code, and returns an airline name if available.
  def airline_name(code)
    if @airline_codes[code]
      @airline_codes[code]
    else
      code
    end
  end
  
  # Takes an airport code, and returns the airport name (if available) and code.
  def airport_name(code)
    if @airport_codes[code]
      "#{@airport_codes[code]} (#{code})"
    else
      code
    end
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
  
    
end
