class Link
	
	attr_reader :x, :y, :input_id, :output_id, :type
	
	def initialize(window, input_id, output_id, type)
		@window, @input_id, @output_id, @type = window, input_id, output_id, type
		
		
		
		@input = @window.find_node(input_id)
		
		@input.set_output(self)
		
		@output = @window.find_node(output_id)
		
		@reverse_dir = @window.point_direction(@output.x, @output.y, @input.x, @input.y)
		@mid_x = (@input.x + @output.x)/2
		@mid_y = (@input.y + @output.y)/2
		
		@in_x = @input.x + Gosu::offset_x(@reverse_dir+90, 3)
		@in_y = @input.y + Gosu::offset_y(@reverse_dir+90, 3)
		
		@out_x = @output.x + Gosu::offset_x(@reverse_dir+90, 3)
		@out_y = @output.y + Gosu::offset_y(@reverse_dir+90, 3)
		
		@mid_offset_x = Gosu::offset_x(@reverse_dir - 40, 10)
		@mid_offset_y = Gosu::offset_y(@reverse_dir - 40, 10)
		
		@out_offset_x = Gosu::offset_x(@reverse_dir, 10)
		@out_offset_y = Gosu::offset_y(@reverse_dir, 10)
		
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
	
	def remove_node_link
		@input.remove_output(self)
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
		
		cam_corelate_x = $window_width/2 - $camera_x*$camera_zoom
		cam_corelate_y = $window_height/2 - $camera_y*$camera_zoom
		
		if @window.point_in_rectangle(@input.x*$camera_zoom + cam_corelate_x, @input.y*$camera_zoom + cam_corelate_y, 0, 0, $window_width, $window_height) or @window.point_in_rectangle(@output.x*$camera_zoom + cam_corelate_x, @output.y*$camera_zoom + cam_corelate_y, 0, 0, $window_width, $window_height)
			
			
			
			
			
			if @type == "repeater"
				
				if @value == 0
					color_new = $off_color
				else
					color_new = $on_color
				end
				
				@window.draw_line(@input.x*$camera_zoom + cam_corelate_x, @input.y*$camera_zoom + cam_corelate_y, color_new, @output.x*$camera_zoom + cam_corelate_x, @output.y*$camera_zoom + cam_corelate_y, color_new, 1)
				
				if $optimized_drawing == false
					@window.draw_line(@mid_x*$camera_zoom + cam_corelate_x, @mid_y*$camera_zoom + cam_corelate_y, color_new, (@mid_x + @mid_offset_x)*$camera_zoom + cam_corelate_x, (@mid_y + @mid_offset_y)*$camera_zoom + cam_corelate_y, color_new, 1)
				end
				
			else
				
				if @value == 0
					color_new = $off_color
				else
					color_new = $on_color
				end
				
				@window.draw_line(@in_x*$camera_zoom + cam_corelate_x, @in_y*$camera_zoom + cam_corelate_y, color_new, (@out_x + @out_offset_x)*$camera_zoom + cam_corelate_x, (@out_y + @out_offset_y)*$camera_zoom + cam_corelate_y, color_new, 1)
				if $optimized_drawing == false
					@window.circle_img.draw_rot((@out_x + @out_offset_x)*$camera_zoom + cam_corelate_x, (@out_y + @out_offset_y)*$camera_zoom + cam_corelate_y, 2, 0, 0.5, 0.5, 0.4*$camera_zoom, 0.4*$camera_zoom, color_new)
				end
				
			end
		end
		
	end
	
end