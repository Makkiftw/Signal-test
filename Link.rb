class Link
	
	attr_reader :x, :y, :input_id, :output_id, :type
	
	def initialize(window, input_id, output_id, type)
		@window, @input_id, @output_id, @type = window, input_id, output_id, type
		
		
		
		@input = @window.find_node(input_id)
		@output = @window.find_node(output_id)
		
		if @type == "repeater"
			@value = 0
		else
			if @input.value == 0
				@value = 1
			else
				@value = 0
			end
		end
		
	end
	
	def update
		
	end
	
	def signal_output
		
		if @value != 0
			if @type == "repeater"
				@output.set_value(@value)
			else
				@output.set_value(@value)
			end
			@value = 0
		end
		
	end
	
	def get_signal(value, id)
		
		if @input_id == id
			
			if @type == "repeater"
				@value = value
			else
				@value = 1-value
			end
		end
		
	end
	
	def draw
		
		color = 0xffffffff
		blue = [color%256, 0].max
		green = [(color/256)%256 - (255*@value).round, 0].max
		red = [(color/65536)%256, 0].max
		alpha = [(color/16777216)%256, 0].max
		
		color_new = alpha*16777216 +
							[[red, 0].max, 255].min*65536 +
							[[green, 0].max, 255].min*256 +
							[[blue, 0].max, 255].min
		
		
		reverse_dir = @window.point_direction(@output.x, @output.y, @input.x, @input.y)
		
		if @type == "repeater"
			
			## @x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom
			
			@window.draw_line(@input.x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @input.y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, @output.x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @output.y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 1)
			
			mid_x = (@input.x + @output.x)/2
			mid_y = (@input.y + @output.y)/2
			
			@window.draw_line(mid_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, mid_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (mid_x + Gosu::offset_x(reverse_dir + 40, 10))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (mid_y + Gosu::offset_y(reverse_dir + 40, 10))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 1)
			@window.draw_line(mid_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, mid_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (mid_x + Gosu::offset_x(reverse_dir - 40, 10))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (mid_y + Gosu::offset_y(reverse_dir - 40, 10))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 1)
			
		else
			
			in_x = @input.x + Gosu::offset_x(reverse_dir+90, 3)
			in_y = @input.y + Gosu::offset_y(reverse_dir+90, 3)
			
			out_x = @output.x + Gosu::offset_x(reverse_dir+90, 3)
			out_y = @output.y + Gosu::offset_y(reverse_dir+90, 3)
			
			@window.draw_line(in_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, in_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (out_x + Gosu::offset_x(reverse_dir, 10))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (out_y + Gosu::offset_y(reverse_dir, 10))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 1)
			@window.circle_img.draw_rot((out_x + Gosu::offset_x(reverse_dir, 10))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (out_y + Gosu::offset_y(reverse_dir, 10))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 2, 0, 0.5, 0.5, 0.4*$camera_zoom, 0.4*$camera_zoom, color_new)
			
		end
	end
	
end