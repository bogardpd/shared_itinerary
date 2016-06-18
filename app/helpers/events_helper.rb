module EventsHelper
  
  def initialize_settings
    # Settable
    
    @row_hue = Hash.new
    @row_hue["TUS"] = 0
    @row_hue["PHX"] = 180

    @lightness_ff_lt = '40%' # Flight fill, layover text
    @lightness_lf_ft = '80%' # Layover fill, flight text
    @lightness_stroke = '30%'
    @saturation = '50%'

    @airport_padding = 3
    @airport_right_buffer = 48
    @arrow_point_length = 5
    @flight_bar_height = 30
    @flight_bar_spacing = 5
    @flight_bar_line_break_width = 40
    @image_padding = 10
    @name_width = 130
    @name_padding = 10
    @pixels_per_hour = 40
    @time_label_height = 18
    @time_label_padding = 5
    
    # Derived:

    @image_width = @name_width + (24*@pixels_per_hour) + 2*@image_padding + @time_label_padding + @airport_right_buffer
    @chart_top = @image_padding + (2 * @time_label_height) + @time_label_padding
    @chart_left = @image_padding + @name_width
    @chart_right = @chart_left + (24 * @pixels_per_hour)
  end
  
  def draw_charts
  	initialize_settings
        
    # Determine earliest and latest dates
  	incoming_date_range = get_date_range(@incoming_flights)
  	returning_date_range = get_date_range(@returning_flights)
	
    concat "<h2>Incoming Flights</h2>\n".html_safe
	
  	for d in incoming_date_range[0]..incoming_date_range[1]
  		draw_date_chart(d,@incoming_flights,true)
  	end
	
  	concat "<h2>Returning Flights</h2>\n".html_safe
	
  	for d in returning_date_range[0]..returning_date_range[1]
  		draw_date_chart(d,@returning_flights,false)
  	end
  end


  def draw_date_chart(date, flight_array, arriving)
	
  	this_date = date
	
  	# Determine number of rows:
  	number_of_rows = 0
  	flight_array.each do |person|
  		contains_flight_with_current_date = false
  		person[1].each do |flight|
  			if (flight[3].to_date == this_date || flight[5].to_date == this_date)
  				contains_flight_with_current_date = true 
  			end
  		end
  		number_of_rows += 1 if contains_flight_with_current_date
  	end
	
  	if number_of_rows > 0
	
  		chart_height = (@flight_bar_height + 2 * @flight_bar_spacing) * number_of_rows
  		image_height = @chart_top + chart_height + @image_padding

  		concat "<svg width=\"#{@image_width}\" height=\"#{image_height}\">\n\n".html_safe
  		concat "<rect width=\"#{@image_width}\" height=\"#{image_height}\" class=\"svg_background\" />\n".html_safe
	
  		concat "<text x=\"#{@image_padding}\" y=\"#{@image_padding}\" class=\"svg_time_date_label\">#{this_date.strftime("%A, %B %-d, %Y")}</text>\n".html_safe
  		concat "<text x=\"#{@image_padding + @name_width + (12 * @pixels_per_hour)}\" y=\"#{@image_padding +  @time_label_height}\" text-anchor=\"middle\" class=\"svg_time_zone_label\">#{@time_zone}</text>\n".html_safe
	
  		# Draw chart grid:
	
  		for x in 0..number_of_rows
  			concat "<line x1=\"#{@image_padding + @name_width}\" y1=\"#{@chart_top + x * (@flight_bar_height + @flight_bar_spacing * 2)}\" x2=\"#{@image_padding + @name_width + 24 * @pixels_per_hour}\" y2=\"#{@chart_top + x * (@flight_bar_height + @flight_bar_spacing * 2)}\" class=\"svg_gridline_minor\" />\n".html_safe 
  		end
	
  		for x in 0..24
  			concat "<text x=\"#{@image_padding + @name_width + (x * @pixels_per_hour)}\" y=\"#{@chart_top - @time_label_padding}\" text-anchor=\"middle\" class=\"svg_time_label\">#{time_label(x)}</text>\n".html_safe
  			concat "<line x1=\"#{@image_padding + @name_width + (x * @pixels_per_hour)}\" y1=\"#{@chart_top}\" x2=\"#{@image_padding + @name_width + (x * @pixels_per_hour)}\" y2=\"#{@chart_top + chart_height + 1}\" class=\"#{x % 12 == 0 ? 'svg_gridline_major' : 'svg_gridline_minor'}\" />\n".html_safe
  		end
	
  		# Draw flight bars:
  		row_index = 0;
  		flight_array.each do |person|
  			# Make sure this person has flights on this date, and if so, draw a row for them:
  			if person[1].any? && (person[1].first)[3].to_date <= this_date && (person[1].last)[5].to_date >= this_date
  				# Get hue:
  				if arriving
  					this_hue = @row_hue[((person[1].last)[4])]
  				else
  					this_hue = @row_hue[((person[1].first)[2])]
  				end
		
  				draw_person_row(person, this_date, row_index, this_hue)
  				row_index += 1
        end		
  		end
	
  		concat "</svg>\n".html_safe

  	end
  end

  def draw_flight_bar(row, hue, flight, this_date)
  	display_flight_number = true
  	start_time = flight[3]
  	end_time = flight[5]
  	left_side = @name_width + @image_padding + (start_time.hour*@pixels_per_hour) + (start_time.min*@pixels_per_hour/60)
  	right_side = @name_width + @image_padding + (end_time.hour*@pixels_per_hour) + (end_time.min*@pixels_per_hour/60)
  	width = right_side - left_side
  	html = ""
  	if flight[3].to_date == this_date && flight[5].to_date == this_date
  		# Flight starts and ends today
  		html += "<rect x=\"#{left_side}\" y=\"#{row_top(row)}\" width=\"#{width}\" height=\"#{@flight_bar_height}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_ff_lt})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  	elsif Date.parse(flight[3]) == this_date && Date.parse(flight[5]) > this_date
  		# Flight starts today and ends tomorrow
  		html += "<polygon points=\"#{left_side},#{row_top(row)} #{@chart_right},#{row_top(row)} #{@chart_right + @arrow_point_length},#{row_top(row) + @flight_bar_height/2} #{@chart_right},#{row_top(row) + @flight_bar_height} #{left_side},#{row_top(row) + @flight_bar_height}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_ff_lt})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  		right_side = @chart_right
  		width = right_side - left_side
  	elsif Date.parse(flight[3]) < this_date && Date.parse(flight[5]) == this_date
  		# Flight starts yesterday and ends today
  		html += "<polygon points=\"#{@chart_left},#{row_top(row)} #{right_side},#{row_top(row)} #{right_side},#{row_top(row) + @flight_bar_height} #{@chart_left},#{row_top(row) + @flight_bar_height} #{@chart_left - @arrow_point_length},#{row_top(row) + @flight_bar_height/2}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_ff_lt})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  		left_side = @chart_left
  		width = right_side - left_side
  	else
  		# No part of the flight occurs today, so do not draw anything
  		display_flight_number = false
  	end
	
  	if display_flight_number
  		if width < @flight_bar_line_break_width
  			html += "<text x=\"#{(left_side + right_side) / 2}\" y=\"#{row_top(row) + @flight_bar_height * 0.3}\" class=\"svg_flight_text\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\">#{flight[0]}</text>\n"
  			html += "<text x=\"#{(left_side + right_side) / 2}\" y=\"#{row_top(row) + @flight_bar_height * 0.7}\" class=\"svg_flight_text\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\">#{flight[1]}</text>\n"
  		else
  			html += "<text x=\"#{(left_side + right_side) / 2}\" y=\"#{row_top(row) + @flight_bar_height / 2}\" class=\"svg_flight_text\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\">#{flight[0]} #{flight[1]}</text>\n"
  		end
  	end
  	html.html_safe
  end

  def draw_layover_bar(row, hue, flight_1, flight_2, this_date)
  	display_layover_airport = true
  	html = ""

  	start_date = (flight_1[5]).to_date
  	end_date = (flight_2[3]).to_date
  	start_time = flight_1[5]
  	end_time = flight_2[3]
		
  	left_side = @name_width + @image_padding + (start_time.hour*@pixels_per_hour) + (start_time.min*@pixels_per_hour/60)
  	right_side = @name_width + @image_padding + (end_time.hour*@pixels_per_hour) + (end_time.min*@pixels_per_hour/60)
  	width = right_side - left_side
	
  	if start_date == this_date && end_date == this_date
  		# Layover starts and ends today
  		html = "<rect x=\"#{left_side}\" y=\"#{row_top(row)}\" width=\"#{width}\" height=\"#{@flight_bar_height}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\"  stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  	elsif start_date == this_date && end_date > this_date
  		# Layover starts today and ends tomorrow
  		html += "<polygon points=\"#{left_side},#{row_top(row)} #{@chart_right},#{row_top(row)} #{@chart_right + @arrow_point_length},#{row_top(row) + @flight_bar_height/2} #{@chart_right},#{row_top(row) + @flight_bar_height} #{left_side},#{row_top(row) + @flight_bar_height}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  		right_side = @chart_right
  		width = right_side - left_side
  	elsif start_date < this_date && end_date == this_date
  		# Layover starts yesterday and ends today
  		html += "<polygon points=\"#{@chart_left},#{row_top(row)} #{right_side},#{row_top(row)} #{right_side},#{row_top(row) + @flight_bar_height} #{@chart_left},#{row_top(row) + @flight_bar_height} #{@chart_left - @arrow_point_length},#{row_top(row) + @flight_bar_height/2}\" class=\"svg_bar\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_lf_ft})\" stroke=\"hsl(#{hue},#{@saturation},#{@lightness_stroke})\" />\n"
  		left_side = @chart_left
  		width = right_side - left_side
  	else
  		# No part of the layover occurs today, so do not draw anything
  		display_layover_airport = false
  	end
	
  	if display_layover_airport
  		html += "<text x=\"#{(left_side + right_side) / 2}\" y=\"#{row_top(row) + @flight_bar_height / 2}\" class=\"svg_layover_text\" fill=\"hsl(#{hue},#{@saturation},#{@lightness_ff_lt})\">#{flight_1[4]}</text>\n"
  	end
  	html.html_safe
  end

  def draw_person_row(person, this_date, row_index, hue)
  	prev_flight = nil
		
  	concat "<text x=\"#{@image_padding + @name_width - @name_padding}\" y=\"#{row_top(row_index) + (@flight_bar_height / 2)}\" class=\"svg_person_name\">#{person[0]}</text>\n".html_safe
	
  	person[1].each_with_index do |flight, flight_index|
  		concat draw_flight_bar(row_index, hue, flight, this_date)
		
  		# Draw layover bars if necessary:
  		unless prev_flight.nil?
  			concat draw_layover_bar(row_index, hue, prev_flight, flight, this_date)
  		end
  		prev_flight = flight
  	end
	
  	start_time = (person[1].first)[3]
  	end_time = (person[1].last)[5]
	
  	section_left = @name_width + @image_padding + (start_time.hour*@pixels_per_hour) + (start_time.min*@pixels_per_hour/60) - @airport_padding
  	section_right = @name_width + @image_padding + (end_time.hour*@pixels_per_hour) + (end_time.min*@pixels_per_hour/60) + @airport_padding
	
  	if ((person[1].first)[3]).to_date == this_date
  		concat "<text x=\"#{section_left}\" y=\"#{row_top(row_index) + @flight_bar_height * 0.25}\" class=\"svg_airport_label svg_airport_block_start\">#{(person[1].first)[2]}</text>\n".html_safe
  		concat "<text x=\"#{section_left}\" y=\"#{row_top(row_index) + @flight_bar_height * 0.75}\" class=\"svg_time_label svg_airport_block_start\">#{((person[1].first)[3]).strftime("%l:%M%P")}</text>\n".html_safe
  	end
	
  	if ((person[1].last)[5]).to_date == this_date
  		concat "<text x=\"#{section_right}\" y=\"#{row_top(row_index) + @flight_bar_height * 0.25}\" class=\"svg_airport_label svg_airport_block_end\">#{(person[1].last)[4]}</text>\n".html_safe
  		concat "<text x=\"#{section_right}\" y=\"#{row_top(row_index) + @flight_bar_height * 0.75}\" class=\"svg_time_label svg_airport_block_end\">#{((person[1].last)[5]).strftime("%l:%M%P")}</text>\n".html_safe
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
  		person[1].each do |flight|
  			if (date_range[0].nil? || flight[3].to_date < date_range[0])
  				date_range[0] = flight[3].to_date
  			end
  			if (date_range[1].nil? || flight[5].to_date > date_range[1])
  				date_range[1] = flight[5].to_date
  			end
  		end
  	end
    
    return date_range
  end
  
  
end
