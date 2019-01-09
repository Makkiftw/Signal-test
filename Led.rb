class Led
	
	attr_reader :x, :y, :id, :size, :value
	
	def initialize(window, x, y, id, size)
		@window, @x, @y, @id, @size = window, x, y, id, size
		
		@value = 0
		
		@input = @window.find_node(@id)
		
		@input.set_output(self)  ### Important
		
	end
	
	def update
		
	end
	
	def check_if_clicked(m_real_x, m_real_y)
		if @window.point_in_rectangle(m_real_x, m_real_y, @x-@size, @y-@size, @x+@size, @y+@size)
			return true
		end
	end
	
	def get_signal(value, id)
		if @id == id
			@value = value
		end
	end
	
	def delete
		@window.destroy_led(self)
	end
	
	def remove_node_link
		@input.remove_output(self)
	end
	
	def draw
		
		if @value == 0
			color_new = $led_off_color
			col = 0x66777777
		else
			color_new = $led_on_color
			col = 0x66ffff00
		end
		
		if $select_start != false
			
			
			m_real_x = (@window.mouse_x-$window_width/2)/$camera_zoom+$camera_x
			m_real_y = (@window.mouse_y-$window_height/2)/$camera_zoom+$camera_y
			
			x1 = [$select_start[0], m_real_x].min
			y1 = [$select_start[1], m_real_y].min
			
			x2 = [$select_start[0], m_real_x].max
			y2 = [$select_start[1], m_real_y].max
			
			if @window.point_in_rectangle(@x, @y, x1, y1, x2, y2)
				color_new = 0xff00aaff
			end
		end
		
		@window.draw_quad((@x-@size)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y-@size)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, (@x+@size)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y-@size)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, (@x+@size)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y+@size)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, (@x-@size)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y+@size)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, 2)
		@window.draw_quad((@x-(@size-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y-(@size-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (@x+(@size-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y-(@size-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (@x+(@size-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y+(@size-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (@x-(@size-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y+(@size-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 2)
		
		
		@window.draw_line(@x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, @input.x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @input.y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 1)
		
	end
	
end