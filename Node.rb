class Node
	
	attr_reader :x, :y, :value, :id, :initial
	
	def initialize(window, x, y, initial, id)
		@window, @x, @y, @initial, @id = window, x, y, initial, id
		
		@value = 0
		
	end
	
	def update
		
		@initial = 0
		@window.transfer_signal(@value, @id)
		
	end
	
	def check_if_clicked(m_real_x, m_real_y)
		if @window.point_in_rectangle(m_real_x, m_real_y, @x-7, @y-7, @x+7, @y+7)
			return true
		end
	end
	
	def delete
		@window.destroy_links(@id)
		@window.destroy_levers(@id)
		@window.destroy_node(self)
	end
	
	def set_value(value)
		
		if @initial == 0
			@value = value
		else
			@window.transfer_signal(@initial, @id)
			@initial = 0
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
		
		@window.circle_img.draw_rot(@x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 2, 0, 0.5, 0.5, 1.0*$camera_zoom, 1.0*$camera_zoom, color_new)
		
		# @window.font.draw("#{@id}", (@x-10)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (@y-20)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 0, 1.0, 1.0, color_new)
		
		m_real_x = (@window.mouse_x-$window_width/2)/$camera_zoom+$camera_x
		m_real_y = (@window.mouse_y-$window_height/2)/$camera_zoom+$camera_y
		
		if @window.cursor == "repeater" or @window.cursor == "inverter" or @window.cursor == "lever"
			if @window.point_in_rectangle(m_real_x, m_real_y, @x-7, @y-7, @x+7, @y+7)
				@window.circle_img.draw_rot(@x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 2, 0, 0.5, 0.5, 1.0*$camera_zoom, 1.0*$camera_zoom, 0xff00ff00)
			end
		end
		
	end
	
end