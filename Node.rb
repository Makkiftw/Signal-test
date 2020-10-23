class Node
	
	attr_reader :x, :y, :value, :id, :initial
	
	def initialize(window, x, y, initial, id)
		@window, @x, @y, @initial, @id = window, x, y, initial, id
		
		@value = 0
		
		@outputs = []
		
	end
	
	def update
		
		@initial = 0
		for i in 0..@outputs.length-1
			@outputs[i].get_signal(@value, @id)
		end
		
	end
	
	def check_if_clicked(m_real_x, m_real_y)
		if @window.point_in_rectangle(m_real_x, m_real_y, @x-7, @y-7, @x+7, @y+7)
			return true
		end
	end
	
	def delete
		@window.destroy_links(@id)
		@window.destroy_leds(@id)
		@window.destroy_levers(@id)
		@window.destroy_node(self)
	end
	
	def set_value(value)
		
		if @initial == 0
			@value = value
		else
			for i in 0..@outputs.length-1
				@outputs[i].get_signal(@initial, @id)
			end
			@initial = 0
		end
		
	end
	
	def set_output(inst)
		@outputs << inst
	end
	
	def remove_output(inst)
		@outputs.delete(inst)
	end
	
	def draw
		m_real_x = (@window.mouse_x-$window_width/2)/$camera_zoom+$camera_x
		m_real_y = (@window.mouse_y-$window_height/2)/$camera_zoom+$camera_y
		if @window.point_in_rectangle(m_real_x, m_real_y, @x-7, @y-7, @x+7, @y+7)
			@window.circle_img.draw_rot(@x*$camera_zoom + $cam_corelate_x, @y*$camera_zoom + $cam_corelate_y, 2, 0, 0.5, 0.5, 1.0*$camera_zoom, 1.0*$camera_zoom, 0xff00ff00)
		end
	end
	
end