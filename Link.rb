class Link
	
	attr_reader :x, :y, :input_id, :output_id, :type, :input, :output
	
	def initialize(window, input, output, type)
		@window, @input, @output, @type = window, input, output, type
		
		@input.set_output(self)
		@input_id = @input.id
		@output_id = @output.id
		
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
		if $draw_links == true
			if @window.point_in_rectangle(@mid_x*$camera_zoom + $cam_corelate_x, @mid_y*$camera_zoom + $cam_corelate_y, 0, 0, $window_width, $window_height)
				if @type == "repeater"
					
					if @value == 0
						color_new = $link_off_color
					else
						color_new = $link_on_color
					end
					
					x1	= @input.x*$camera_zoom + $cam_corelate_x
					y1	= @input.y*$camera_zoom + $cam_corelate_y
					c1	= color_new
					x2	= @output.x*$camera_zoom + $cam_corelate_x
					y2	= @output.y*$camera_zoom + $cam_corelate_y
					c2	= color_new
					z	= 1
					@window.draw_line(x1, y1, c1, x2, y2, c2, z)
					
					if $optimized_drawing == false
						
						x1	= @mid_x*$camera_zoom + $cam_corelate_x
						y1	= @mid_y*$camera_zoom + $cam_corelate_y
						c1	= color_new
						x2	= (@mid_x + @mid_offset_x)*$camera_zoom + $cam_corelate_x
						y2	= (@mid_y + @mid_offset_y)*$camera_zoom + $cam_corelate_y
						c2	= color_new
						z	= 1
						@window.draw_line(x1, y1, c1, x2, y2, c2, z)
					end
					
				else
					
					if @value == 0
						color_new = $link_off_color
					else
						color_new = $link_on_color
					end
					
					x1	= @in_x*$camera_zoom + $cam_corelate_x
					y1	= @in_y*$camera_zoom + $cam_corelate_y
					c1	= color_new
					x2	= (@out_x + @out_offset_x)*$camera_zoom + $cam_corelate_x
					y2	= (@out_y + @out_offset_y)*$camera_zoom + $cam_corelate_y
					c2	= color_new
					z	= 1
					@window.draw_line(x1, y1, c1, x2, y2, c2, z)
					
					if $optimized_drawing == false
						@window.circle_img.draw_rot((@out_x + @out_offset_x)*$camera_zoom + $cam_corelate_x, (@out_y + @out_offset_y)*$camera_zoom + $cam_corelate_y, 2, 0, 0.5, 0.5, 0.4*$camera_zoom, 0.4*$camera_zoom, color_new)
					end
					
				end
			end
		end
	end
	
end