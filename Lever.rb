class Lever
	
	attr_reader :x, :y, :id, :size, :value
	
	def initialize(window, x, y, id, size, value)
		@window, @x, @y, @id, @size, @value = window, x, y, id, size, value
		
		# @value = 0
		
		@output = @window.find_node(@id)
		
	end
	
	def update
		
	end
	
	def check_if_clicked(m_real_x, m_real_y)
		if @window.point_in_rectangle(m_real_x, m_real_y, @x-7, @y-7, @x+7, @y+7)
			return true
		end
	end
	
	def delete
		@window.destroy_lever(self)
	end
	
	def mouse_click
		
		m_real_x = (@window.mouse_x-$window_width/2)/$camera_zoom+$camera_x
		m_real_y = (@window.mouse_y-$window_height/2)/$camera_zoom+$camera_y
		
		if @window.point_in_rectangle(m_real_x, m_real_y, @x-@size, @y-@size, @x+@size, @y+@size)
			if @value == 0
				@value = 1
			else
				@value = 0
			end
		end
	end
	
	def give_signal
		
		## Only send signal when value is 1
		if @value == 1
			@output.set_value(@value)
		end
		
	end
	
	def draw
		
		if @value == 0
			color_new = $off_color
		else
			color_new = $on_color
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
		
		col = 0xff777777
		
		@window.draw_quad((@x-@size)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y-@size)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, (@x+@size)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y-@size)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, (@x+@size)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y+@size)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, (@x-@size)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y+@size)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, 2)
		@window.draw_quad((@x-(@size-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y-(@size-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (@x+(@size-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y-(@size-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (@x+(@size-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y+(@size-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (@x-(@size-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y+(@size-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 2)
		
		
		@window.draw_line(@x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, @output.x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @output.y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 1)
		
	end
	
end