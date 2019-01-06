class TextFlash
	
	def initialize(window, x, y, text, camera, color, moving, size, lifetime)
		@window, @x, @y, @text, @camera, @color, @moving, @size, @lifetime = window, x, y, text, camera, color, moving, size, lifetime
	end
	
	def update
		
		@lifetime = [@lifetime-1, 0].max
		if @lifetime == 0
			@window.destroy_textflash(self)
		end
		
		if @moving == true
			@y = @y-0.5
		end
		
	end
	
	def draw
		
		colorr = @color
			
		blue = colorr%256
		green = (colorr/256)%256
		red = (colorr/65536)%256
		alpha = (colorr*([@lifetime/60.0, 1.0].min)/16777216).floor%256
		
		new_color = alpha*16777216 +
						[[red, 0].max, 255].min*65536 +
						[[green, 0].max, 255].min*256 +
						[[blue, 0].max, 255].min

		if @camera == true
			case @size
				when "big"
					@window.bigfont.draw("#{@text}", @x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 2.5, 1.0, 1.0, new_color)
				when "normal"
					@window.font.draw("#{@text}", @x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 2.5, 1.0, 1.0, new_color)
				when "small"
					@window.smallfont.draw("#{@text}", @x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 2.5, 1.0, 1.0, new_color)
			end
		else
			case @size
				when "big"
					@window.bigfont.draw("#{@text}", @x, @y, 2.5, 1.0, 1.0, new_color)
				when "normal"
					@window.font.draw("#{@text}", @x, @y, 2.5, 1.0, 1.0, new_color)
				when "small"
					@window.smallfont.draw("#{@text}", @x, @y, 2.5, 1.0, 1.0, new_color)
			end
		end
	end
	
end