require 'rubygems'
require 'gosu'

include Gosu

require_relative 'Node.rb'
require_relative 'Link.rb'
require_relative 'Lever.rb'
require_relative 'Textflash.rb'

class GameWindow < Gosu::Window
	
	WIDTH = 800
	HEIGHT = 600
	TITLE = "Just another ruby project"
	
	attr_reader :circle_img, :font, :bigfont, :cursor
	
	def initialize
		
		super(WIDTH, HEIGHT, false)
		self.caption = TITLE
		
		$window_width = WIDTH
		$window_height = HEIGHT
		
		$camera_x = $window_width/2
		$camera_y = $window_height/2
		$camera_zoom = 1.0
		
		## The colors used in the circuits
		$off_color = 0xffffffff  ## White
		$on_color = 0xffff00ff   ## Purple
		
		@circle_img = Gosu::Image.new(self, "media/dot_img.png", true)
		
		@font = Gosu::Font.new(self, Gosu::default_font_name, 17)
		@bigfont = Gosu::Font.new(self, Gosu::default_font_name, 20)
		@smallfont = Gosu::Font.new(self, Gosu::default_font_name, 14)
		@smallerfont = Gosu::Font.new(self, Gosu::default_font_name, 12)
		
		## Visual stuff
		$textflash = []
		
		## Array of nodes
		$nodes = []
		@node_ids = []
		## Array of links
		$links = []
		## Array of levers
		$levers = []
		
		
		ary = self.get_file_data
		# p ary
		
		for i in 0..ary.length-1
			case ary[i][0]
				when "node"
					self.create_node_id(ary[i][1].to_i, ary[i][2].to_i, ary[i][3].to_i, ary[i][4].to_i)
				when "link"
					self.create_link(ary[i][1].to_i, ary[i][2].to_i, ary[i][3])
				when "lever"
					self.create_lever(ary[i][1].to_i, ary[i][2].to_i, ary[i][3].to_i, ary[i][4].to_i, ary[i][5].to_i)
			end
		end
		
		@update_delay_max = 5
		@update_delay = @update_delay_max
		
		@cursor = false
		@cursor_input = false
		$select_start = false
		@copy_data = false
		
		@toggle_grid = false
		@grid_size = 20
		
	end
	
	def update
		self.caption = "Signal test  -  [FPS: #{Gosu::fps.to_s}]"
		
		if button_down? Gosu::KbW or button_down? Gosu::KbUp
			$camera_y += -5 / $camera_zoom
		end
		if button_down? Gosu::KbA or button_down? Gosu::KbLeft
			$camera_x += -5 / $camera_zoom
		end
		if button_down? Gosu::KbS or button_down? Gosu::KbDown
			$camera_y += 5 / $camera_zoom
		end
		if button_down? Gosu::KbD or button_down? Gosu::KbRight
			$camera_x += 5 / $camera_zoom
		end
		if button_down? Gosu::KbQ
			$camera_zoom = $camera_zoom * 0.98
		end
		if button_down? Gosu::KbE
			$camera_zoom = $camera_zoom / 0.98
		end
		if button_down? Gosu::MsRight
			ary = []
			dists = []
			x = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
			y = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
			$nodes.each   { |inst|  
			if inst.check_if_clicked(x, y) == true
				ary << inst
				dists << Gosu::distance(x, y, inst.x, inst.y)
			end
			}
			$levers.each   { |inst|  
			if inst.check_if_clicked(x, y) == true
				ary << inst
				dists << Gosu::distance(x, y, inst.x, inst.y)
			end
			}
			if dists.empty? == false
				min_index = dists.each_with_index.min[1] ## Index of closest node
				inst = ary[min_index] ## inst of closest node
				
				# puts dists.length
				
				inst.delete
				
			end
		end
		
		@update_delay = [@update_delay-1, 0].max
		
		if @update_delay == 0
			@update_delay = @update_delay_max
			
			$nodes.each  { |inst|  inst.set_value(0) }
			$levers.each { |inst|  inst.give_signal }
			$links.each  { |inst|  inst.signal_output }
			$nodes.each  { |inst|  inst.update }
			
		end
		
		$textflash.each { |inst|  inst.update }
		
	end
	
	def transfer_signal(value, id)
		$links.each { |inst|  inst.get_signal(value, id) }
	end
	
	def create_node_id(x, y, value, id)
		
		@node_ids << id
		inst = Node.new(self, x, y, value, id)
		$nodes << inst
		
	end
	
	def create_node(x, y, value)
		### A MAXIMUM OF 1000 IDS AT THE SAME TIME!!! ELSE THE INSTANCE WONT BE CREATED!
		for i in 0..9999
			if !@node_ids.include? i
				id = i
				@node_ids << id
				## Actually create the player
				inst = Node.new(self, x, y, value, id)
				$nodes << inst
				## Break the loop
				return inst
				break
			end
		end
		
		
	end
	
	def create_link(input, output, type)
		inst = Link.new(self, input, output, type)
		$links << inst
	end
	
	def create_lever(x, y, id, size, value)
		inst = Lever.new(self, x, y, id, size, value)
		$levers << inst
	end
	
	def create_textflash(x, y, text, camera, color, moving, size, lifetime)
		inst = TextFlash.new(self, x, y, text, camera, color, moving, size, lifetime)
		$textflash << inst
	end
	
	def destroy_textflash(id)
		$textflash.delete(id)
	end
	
	def destroy_links(id)
		$links.each_with_index   { |inst, i|  
		if inst.input_id == id or inst.output_id == id
			$links[i] = nil
		end
		}
		$links.delete(nil)
	end
	
	def destroy_levers(id)
		$levers.each_with_index   { |inst, i|  
		if inst.id == id
			$levers[i] = nil
		end
		}
		$levers.delete(nil)
	end
	
	def destroy_node(id)
		@node_ids.delete(id.id) ## makes sense
		$nodes.delete(id)
	end
	
	def destroy_lever(id)
		$levers.delete(id)
	end
	
	def find_node(id)
		for i in 0..$nodes.length-1
			if $nodes[i].id == id
				return $nodes[i]
			end
		end
	end
	
	def copy_selection
		
		## Real coordinates
		m_real_x = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
		m_real_y = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
		
		## The minimum is taken to be compatible with reverse-direction-selections
		sel_x1 = [$select_start[0], m_real_x].min  ### Real
		sel_y1 = [$select_start[1], m_real_y].min  ### Real
		
		sel_x2 = [$select_start[0], m_real_x].max  ### Real
		sel_y2 = [$select_start[1], m_real_y].max  ### Real
		
		mid_x = (sel_x1+sel_x2)/2
		mid_y = (sel_y1+sel_y2)/2
		
		
		copy_nodes = []
		node_ids = []
		copy_links = []
		copy_levers = []
		
		for i in 0..$nodes.length-1
			if self.point_in_rectangle($nodes[i].x, $nodes[i].y, sel_x1, sel_y1, sel_x2, sel_y2)
				copy_nodes << $nodes[i]
				node_ids << $nodes[i].id
			end
		end
		
		for i in 0..$levers.length-1
			if self.point_in_rectangle($levers[i].x, $levers[i].y, sel_x1, sel_y1, sel_x2, sel_y2) and node_ids.include?($levers[i].id)
				copy_levers << $levers[i]
			end
		end
		
		for i in 0..$links.length-1
			if node_ids.include?($links[i].input_id) and node_ids.include?($links[i].output_id)
				copy_links << $links[i]
			end
		end
		
		puts "copy_nodes.length #{copy_nodes.length}"
		puts "node_ids.length #{node_ids.length}"
		puts "copy_levers.length #{copy_levers.length}"
		puts "copy_links.length #{copy_links.length}"
		
		if copy_nodes.empty? == false
			
			## The actual data that will be saved for the pasteboard. Some values need to be recalculated first.
			data_nodes = []
			data_levers = []
			data_links = []
			
			for i in 0..copy_nodes.length-1
				x_related = copy_nodes[i].x - mid_x
				y_related = copy_nodes[i].y - mid_y
				id_real = copy_nodes[i].id
				id_copy = i
				value_copy = copy_nodes[i].value
				
				data_nodes << [x_related, y_related, value_copy]
				# data_ids << id_real
				# We already have node_ids
			end
			
			if copy_levers.empty? == false
				for i in 0..copy_levers.length-1
					x_related = copy_levers[i].x - mid_x
					y_related = copy_levers[i].y - mid_y
					id_real = copy_levers[i].id
					id_copy = node_ids.find_index(id_real)
					value_copy = copy_levers[i].value
					
					data_levers << [x_related, y_related, value_copy, id_copy]
					
				end
			end
			
			if copy_links.empty? == false
				for i in 0..copy_links.length-1
					id_input_real = copy_links[i].input_id
					id_input_copy = node_ids.find_index(id_input_real)
					
					id_output_real = copy_links[i].output_id
					id_output_copy = node_ids.find_index(id_output_real)
					
					type_copy = copy_links[i].type
					
					data_links << [id_input_copy, id_output_copy, type_copy]
				end
			end
			
			self.create_textflash($window_width/2-20, 50, "Copied to pasteboard!", false, 0xffffffff, false, "big", 100)
			
			## @copy_data includes no instances, making it light and convenient to use, even if the instances the data represent gets deleted!
			@copy_data = [[mid_x, mid_y], data_nodes, node_ids, data_levers, data_links]
			@cursor = false
			p @copy_data
			
			puts "mid_x: #{mid_x}"
			puts "mid_y: #{mid_y}"
			
			gridmid_x = (mid_x-@grid_size/2) % @grid_size
			gridmid_y = (mid_y-@grid_size/2) % @grid_size
			
			puts "gridmid_x: #{gridmid_x}"
			puts "gridmid_y: #{gridmid_y}"
			
		end
		
	end
	
	def get_file_data
		
		filedata = []
		this_line = []
		
		File.open('savefile.txt') do |f|
			f.lines.each do |line|
				this_line = line.split
				filedata << this_line
			end
		end
		
		return filedata
		
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::MsLeft
				if point_in_rectangle(mouse_x, mouse_y, 7, 7, 69, 39)
					self.create_textflash($window_width/2-20, 50, "Saved!", false, 0xffffffff, false, "big", 100)
					
					save_text = ""
					for i in 0..$nodes.length-1
						save_text << "node #{$nodes[i].x} #{$nodes[i].y} #{$nodes[i].value} #{$nodes[i].id}\n"
					end
					for i in 0..$links.length-1
						save_text << "link #{$links[i].input_id} #{$links[i].output_id} #{$links[i].type}\n"
					end
					for i in 0..$levers.length-1
						save_text << "lever #{$levers[i].x} #{$levers[i].y} #{$levers[i].id} #{$levers[i].size} #{$levers[i].value}\n"
					end
					# puts save_text
					File.open('savefile.txt', "w") {|f| f.write(save_text) }
					@cursor = false
					@cursor_input = false
				elsif point_in_rectangle(mouse_x, mouse_y, 491, 7, 550, 39)
					@toggle_grid = !@toggle_grid
					@cursor = false
					@cursor_input = false
				elsif point_in_rectangle(mouse_x, mouse_y, 108, 7, 177, 39)
					if @cursor == "node"
						@cursor = false
					else
						@cursor = "node"
					end
					@cursor_input = false
				elsif point_in_rectangle(mouse_x, mouse_y, 184, 7, 282, 39)
					if @cursor == "repeater"
						@cursor = false
					else
						@cursor = "repeater"
					end
					@cursor_input = false
				elsif point_in_rectangle(mouse_x, mouse_y, 289, 7, 372, 39)
					if @cursor == "inverter"
						@cursor = false
					else
						@cursor = "inverter"
					end
					@cursor_input = false
				elsif point_in_rectangle(mouse_x, mouse_y, 379, 7, 452, 39)
					if @cursor == "lever"
						@cursor = false
					else
						@cursor = "lever"
					end
					@cursor_input = false
				elsif point_in_rectangle(mouse_x, mouse_y, 7, 60, 69, 92)
					if @cursor == "copy"
						@cursor = false
					else
						@cursor = "copy"
					end
					@cursor_input = false
				elsif point_in_rectangle(mouse_x, mouse_y, 7, 100, 69, 132)
					if @cursor == "paste"
						@cursor = false
					else
						if @copy_data != false
							@cursor = "paste"
						end
					end
					@cursor_input = false
				else
					if @cursor == "node"
						
						if @toggle_grid == false
							m_real_x = ((mouse_x-$window_width/2)/$camera_zoom+$camera_x).round
							m_real_y = ((mouse_y-$window_height/2)/$camera_zoom+$camera_y).round
							
							self.create_node(m_real_x, m_real_y, 0)
						else
							m_real_x = ((mouse_x-@grid_size*$camera_zoom/2)-$window_width/2)/$camera_zoom+$camera_x
							m_real_y = ((mouse_y-@grid_size*$camera_zoom/2)-$window_height/2)/$camera_zoom+$camera_y
							
							grid_x = (m_real_x*1.0/@grid_size).ceil*@grid_size
							grid_y = (m_real_y*1.0/@grid_size).ceil*@grid_size
							
							self.create_node(grid_x, grid_y, 0)
						end
						
						
					elsif @cursor == "repeater" or @cursor == "inverter"
						
						ary = []
						dists = []
						x = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
						y = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
						$nodes.each   { |inst|  
						if inst.check_if_clicked(x, y) == true
							ary << inst
							dists << Gosu::distance(x, y, inst.x, inst.y)
						end
						}
						if dists.empty? == false
							
							min_index = dists.each_with_index.min[1] ## Index of closest node
							inst = ary[min_index] ## inst of closest node
							
							if @cursor_input == false
								@cursor_input = inst
							else
								repeater_output = inst
								
								if @cursor_input.id != repeater_output.id
									
									already_linked = false
									
									$links.each_with_index   { |inst, i|  
									if inst.input_id == @cursor_input.id and inst.output_id == repeater_output.id
										
										already_linked = true
										
									end
									}
									
									if already_linked == false
										self.create_link(@cursor_input.id, repeater_output.id, @cursor)
										puts "Link created"
									end
								end
								
								@cursor_input = false
								
							end
							
						end
						
					elsif @cursor == "lever"
						if @cursor_input == false
							
							
							
							ary = []
							dists = []
							x = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
							y = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
							$nodes.each   { |inst|  
							if inst.check_if_clicked(x, y) == true
								ary << inst
								dists << Gosu::distance(x, y, inst.x, inst.y)
							end
							}
							if dists.empty? == false
								min_index = dists.each_with_index.min[1] ## Index of closest node
								inst = ary[min_index] ## inst of closest node
								
								@cursor_input = inst
								
							end
							
						else
							
							if @toggle_grid == false
								
								x = ((mouse_x-$window_width/2)/$camera_zoom+$camera_x).round
								y = ((mouse_y-$window_height/2)/$camera_zoom+$camera_y).round
								
								self.create_lever(x, y, @cursor_input.id, 7, 0)
								
							else
								
								m_real_x = ((mouse_x-@grid_size*$camera_zoom/2)-$window_width/2)/$camera_zoom+$camera_x
								m_real_y = ((mouse_y-@grid_size*$camera_zoom/2)-$window_height/2)/$camera_zoom+$camera_y
								
								grid_x = (m_real_x*1.0/@grid_size).ceil*@grid_size
								grid_y = (m_real_y*1.0/@grid_size).ceil*@grid_size
								
								self.create_lever(grid_x, grid_y, @cursor_input.id, 7, 0)
								
							end
							
							@cursor_input = false
						end
					elsif @cursor == "copy"
						
						if $select_start == false
							
							m_real_x = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
							m_real_y = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
							
							$select_start = [m_real_x, m_real_y]
							
						else
							
							## Copy stuff
							self.copy_selection
							
							$select_start = false
						end
					elsif @cursor == "paste" 
						if @copy_data != false
							
							### Paste content!!
							mid_x = @copy_data[0][0]
							mid_y = @copy_data[0][1]
							
							data_nodes = @copy_data[1]
							node_ids = @copy_data[2]
							data_levers = @copy_data[3]
							data_links = @copy_data[4]
							
							
							mid_x = data_nodes[0][0]
							mid_y = data_nodes[0][1]
							
							gridmid_x = (mid_x-@grid_size/2) % @grid_size
							gridmid_y = (mid_y-@grid_size/2) % @grid_size
							
							if @toggle_grid == true
								
								m_real_x1 = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
								m_real_y1 = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
								
								m_real_x = ((m_real_x1)*1.0/@grid_size).ceil*@grid_size - gridmid_x + @grid_size/2
								m_real_y = ((m_real_y1)*1.0/@grid_size).ceil*@grid_size - gridmid_y + @grid_size/2
								
							else
								
								m_real_x = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
								m_real_y = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
							end
							
							
							# m_real_x = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
							# m_real_y = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
							
							new_nodes = []
							
							for i in 0..data_nodes.length-1
								nx = data_nodes[i][0] + m_real_x  ## Real
								ny = data_nodes[i][1] + m_real_y  ## Real
								
								inst = self.create_node(nx, ny, data_nodes[i][2])
								
								new_nodes << inst
								
							end
							for i in 0..data_levers.length-1
								nx = data_levers[i][0] + m_real_x  ## Real
								ny = data_levers[i][1] + m_real_y  ## Real
								
								copy_id = data_levers[i][3] ## The id value in the pasteboard
								real_id = new_nodes[copy_id].id ## The real ID of the node we just created
								
								self.create_lever(nx, ny, real_id, 7, data_levers[i][2])
							end
							for i in 0..data_links.length-1
								
								type = data_links[i][2]
								
								input_copy_id = data_links[i][0]
								output_copy_id = data_links[i][1]
								
								input_real_id = new_nodes[input_copy_id].id
								output_real_id = new_nodes[output_copy_id].id
								
								self.create_link(input_real_id, output_real_id, type)
								
							end
							
						end
					else
						$levers.each   { |inst|  inst.mouse_click }
					end
				end
			when Gosu::KbR
				if @cursor == "repeater" or @cursor == "inverter"
					
					ary = []
					dists = []
					x = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
					y = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
					$nodes.each   { |inst|  
					if inst.check_if_clicked(x, y) == true
						ary << inst
						dists << Gosu::distance(x, y, inst.x, inst.y)
					end
					}
					if dists.empty? == false
						
						min_index = dists.each_with_index.min[1] ## Index of closest node
						inst = ary[min_index] ## inst of closest node
						
						if @cursor_input == false
							@cursor_input = inst
						else
							repeater_output = inst
							
							if @cursor_input.id != repeater_output.id
								self.create_link(@cursor_input.id, repeater_output.id, @cursor)
							end
							
							# @cursor_input = false
							
						end
						
					end
				end
		end
	end
	
	def draw
		## Background
		color = 0xff223344
		self.draw_quad(0, 0, color, $window_width, 0, color, $window_width, $window_height, color, 0, $window_height, color, 0)
		
		if @toggle_grid == true
			
			vert_lines = ($window_width*1.0/(@grid_size*$camera_zoom)+1).round
			hori_lines = ($window_height*1.0/(@grid_size*$camera_zoom)+1).round
			
			x_edge = $camera_x - $window_width/(2*$camera_zoom)  ### Real coordinate of the edge of the window, shifted by @grid_size/2
			y_edge = $camera_y - $window_height/(2*$camera_zoom)  ### Real coordinate of the edge of the window, shifted by @grid_size/2
			
			## Draw the vertical lines
			for i in 0..vert_lines-1
				x = (x_edge*1.0/@grid_size).ceil*@grid_size + i*@grid_size - @grid_size/2
				
				y1 = 0
				y2 = $window_height
				
				col = 0x44ffffff
				
				self.draw_line(x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, y1, col, x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, y2, col, 0)
			end
			
			## Draw the horizontal lines
			for i in 0..hori_lines-1
				y = (y_edge*1.0/@grid_size).ceil*@grid_size + i*@grid_size - @grid_size/2
				
				x1 = 0
				x2 = $window_width
				
				col = 0x44ffffff
				
				self.draw_line(x1, y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, x2, y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, 0)
			end
			
		end
		
		$nodes.each   { |inst|  inst.draw }
		$links.each   { |inst|  inst.draw }
		$levers.each  { |inst|  inst.draw }
		$textflash.each { |inst|  inst.draw }
		
		@font.draw("@update_delay: #{@update_delay}", $window_width-150, 10, 1, 1.0, 1.0, 0xffffffff)
		
		## Save button
		if point_in_rectangle(mouse_x, mouse_y, 7, 7, 69, 39)
			color1 = 0xff000000
			color2 = 0xffffff00
		else
			color1 = 0x88888888
			color2 = 0xffffffff
		end
		self.draw_quad(7, 7, color1, 69, 7, color1, 69, 39, color1, 7, 39, color1, 4)
		self.draw_quad(10, 10, color2, 66, 10, color2, 66, 36, color2, 10, 36, color2, 4)
		@bigfont.draw("Save", 16, 13, 5, 1.0, 1.0, 0xff000000)
		
		## Node button
		a = 108
		b = 7
		c = 177
		d = 39
		if @cursor == "node"
			color1 = 0xff000000
			color2 = 0xffffff00
		else
			if point_in_rectangle(mouse_x, mouse_y, a, b, c, d)
				color1 = 0xff000000
			else
				color1 = 0x88888888
			end
			color2 = 0xffffffff
		end
		self.draw_quad(a, b, color1, c, b, color1, c, d, color1, a, d, color1, 4)
		self.draw_quad(a+3, b+3, color2, c-3, b+3, color2, c-3, d-3, color2, a+3, d-3, color2, 4)
		@bigfont.draw("Node", a+9, b+6, 5, 1.0, 1.0, 0xff000000)
		if @cursor == "node"
			if @toggle_grid == true
				
				m_real_x = ((mouse_x-@grid_size*$camera_zoom/2)-$window_width/2)/$camera_zoom+$camera_x
				m_real_y = ((mouse_y-@grid_size*$camera_zoom/2)-$window_height/2)/$camera_zoom+$camera_y
				
				grid_x = (m_real_x*1.0/@grid_size).ceil*@grid_size
				grid_y = (m_real_y*1.0/@grid_size).ceil*@grid_size
				
				@circle_img.draw_rot(grid_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, grid_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 5, 0, 0.5, 0.5, 1.0*$camera_zoom, 1.0*$camera_zoom, 0xff00ff00)
				
			else
				@circle_img.draw_rot(mouse_x, mouse_y, 5, 0, 0.5, 0.5, 1.0*$camera_zoom, 1.0*$camera_zoom, 0xff00ff00)
			end
		end
		
		## Repeater button
		a = 184
		b = 7
		c = 282
		d = 39
		if @cursor == "repeater"
			color1 = 0xff000000
			color2 = 0xffffff00
		else
			if point_in_rectangle(mouse_x, mouse_y, a, b, c, d)
				color1 = 0xff000000
			else
				color1 = 0x88888888
			end
			color2 = 0xffffffff
		end
		self.draw_quad(a, b, color1, c, b, color1, c, d, color1, a, d, color1, 4)
		self.draw_quad(a+3, b+3, color2, c-3, b+3, color2, c-3, d-3, color2, a+3, d-3, color2, 4)
		@bigfont.draw("Repeater", a+9, b+6, 5, 1.0, 1.0, 0xff000000)  ## AKA Buffer
		if @cursor == "repeater"
			
			if @cursor_input == false
				self.draw_line(mouse_x-7, mouse_y, 0xffffffff, mouse_x+7, mouse_y, 0xffffffff, 5)
			else
				self.draw_line(@cursor_input.x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @cursor_input.y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 0xffffffff, mouse_x, mouse_y, 0xffffffff, 5)
			end
			
		end
		
		## Inverter button
		a = 289
		b = 7
		c = 372
		d = 39
		if @cursor == "inverter"
			color1 = 0xff000000
			color2 = 0xffffff00
		else
			if point_in_rectangle(mouse_x, mouse_y, a, b, c, d)
				color1 = 0xff000000
			else
				color1 = 0x88888888
			end
			color2 = 0xffffffff
		end
		self.draw_quad(a, b, color1, c, b, color1, c, d, color1, a, d, color1, 4)
		self.draw_quad(a+3, b+3, color2, c-3, b+3, color2, c-3, d-3, color2, a+3, d-3, color2, 4)
		@bigfont.draw("Inverter", a+9, b+6, 5, 1.0, 1.0, 0xff000000)  ## AKA "NOT Gate"
		if @cursor == "inverter"
			if @cursor_input == false
				self.draw_line(mouse_x-7, mouse_y, 0xffffffff, mouse_x+7, mouse_y, 0xffffffff, 5)
				@circle_img.draw_rot(mouse_x+7, mouse_y, 5, 0, 0.5, 0.5, 0.4, 0.4, 0xffffffff)
			else
				self.draw_line(@cursor_input.x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @cursor_input.y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 0xffffffff, mouse_x, mouse_y, 0xffffffff, 5)
			end
		end
		
		## Lever button
		a = 379
		b = 7
		c = 452
		d = 39
		if @cursor == "lever"
			color1 = 0xff000000
			color2 = 0xffffff00
		else
			if point_in_rectangle(mouse_x, mouse_y, a, b, c, d)
				color1 = 0xff000000
			else
				color1 = 0x88888888
			end
			color2 = 0xffffffff
		end
		self.draw_quad(a, b, color1, c, b, color1, c, d, color1, a, d, color1, 4)
		self.draw_quad(a+3, b+3, color2, c-3, b+3, color2, c-3, d-3, color2, a+3, d-3, color2, 4)
		@bigfont.draw("Lever", a+9, b+6, 5, 1.0, 1.0, 0xff000000) 
		if @cursor == "lever"
			if @cursor_input == false
				## Do nothing
			else
				
				if @toggle_grid == true
					
					m_real_x = ((mouse_x-@grid_size*$camera_zoom/2)-$window_width/2)/$camera_zoom+$camera_x
					m_real_y = ((mouse_y-@grid_size*$camera_zoom/2)-$window_height/2)/$camera_zoom+$camera_y
					
					grid_x = (m_real_x*1.0/@grid_size).ceil*@grid_size
					grid_y = (m_real_y*1.0/@grid_size).ceil*@grid_size
					
					mid_x = grid_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom
					mid_y = grid_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom
					
					x1 = mid_x-7*$camera_zoom
					y1 = mid_y-7*$camera_zoom
					x2 = mid_x+7*$camera_zoom
					y2 = mid_y+7*$camera_zoom
					
					self.draw_quad(x1, y1, 0xff00ff00, x2, y1, 0xff00ff00, x2, y2, 0xff00ff00, x1, y2, 0xff00ff00, 5)
					self.draw_line(@cursor_input.x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @cursor_input.y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 0xffffffff, mid_x, mid_y, 0xffffffff, 5)
				
				else
					mid_x = mouse_x
					mid_y = mouse_y
					
					x1 = mid_x-7*$camera_zoom
					y1 = mid_y-7*$camera_zoom
					x2 = mid_x+7*$camera_zoom
					y2 = mid_y+7*$camera_zoom
					
					self.draw_quad(x1, y1, 0xff00ff00, x2, y1, 0xff00ff00, x2, y2, 0xff00ff00, x1, y2, 0xff00ff00, 5)
					self.draw_line(@cursor_input.x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, @cursor_input.y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 0xffffffff, mid_x, mid_y, 0xffffffff, 5)
				end
				
			end
		end
		
		## Grid button
		a = 491
		b = 7
		c = 550
		d = 39
		if point_in_rectangle(mouse_x, mouse_y, a, b, c, d)
			color1 = 0xff000000
			color2 = 0xffffff00
		else
			color1 = 0x88888888
			color2 = 0xffffffff
		end
		self.draw_quad(a, b, color1, c, b, color1, c, d, color1, a, d, color1, 4)
		self.draw_quad(a+3, b+3, color2, c-3, b+3, color2, c-3, d-3, color2, a+3, d-3, color2, 4)
		@bigfont.draw("Grid", a+9, b+6, 5, 1.0, 1.0, 0xff000000) 
		
		## Copy button
		a = 7
		b = 60
		c = 69
		d = 92
		if @cursor == "copy"
			color1 = 0xff000000
			color2 = 0xffffff00
		else
			if point_in_rectangle(mouse_x, mouse_y, a, b, c, d)
				color1 = 0xff000000
			else
				color1 = 0x88888888
			end
			color2 = 0xffffffff
		end
		self.draw_quad(a, b, color1, c, b, color1, c, d, color1, a, d, color1, 4)
		self.draw_quad(a+3, b+3, color2, c-3, b+3, color2, c-3, d-3, color2, a+3, d-3, color2, 4)
		@bigfont.draw("Copy", a+9, b+6, 5, 1.0, 1.0, 0xff000000) 
		if @cursor == "copy"
			
			col = 0xff00aaff
			
			self.draw_line(mouse_x-9, mouse_y, col, mouse_x+9, mouse_y, col, 5)
			self.draw_line(mouse_x, mouse_y-9, col, mouse_x, mouse_y+9, col, 5)
			
			if $select_start != false
				
				x_start = $select_start[0]*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom  ## not real
				y_start = $select_start[1]*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom  ## not real
				
				self.draw_line(x_start-9, y_start, col, x_start+9, y_start, col, 5)
				self.draw_line(x_start, y_start-9, col, x_start, y_start+9, col, 5)
				
				mid_x = (x_start+mouse_x)/2  ## not real
				mid_y = (y_start+mouse_y)/2  ## not real
				
				self.draw_line(mid_x-4, mid_y-4, col, mid_x+4, mid_y+4, col, 5)
				self.draw_line(mid_x-4, mid_y+4, col, mid_x+4, mid_y-4, col, 5)
				
				col_quad = 0x440099ff
				
				self.draw_quad(x_start, y_start, col_quad, mouse_x, y_start, col_quad, mouse_x, mouse_y, col_quad, x_start, mouse_y, col_quad, 5)
				
			end
		end
		
		## Paste button
		a = 7
		b = 100
		c = 69
		d = 132
		
		if @copy_data == false
			color2 = 0xffaaaaaa
		else
			color2 = 0xffffffff
			if @cursor == "paste"
				color2 = 0xffffff00
			end
		end
		
		if point_in_rectangle(mouse_x, mouse_y, a, b, c, d)
			color1 = 0xff000000
		else
			color1 = 0x88888888
		end
		
		self.draw_quad(a, b, color1, c, b, color1, c, d, color1, a, d, color1, 4)
		self.draw_quad(a+3, b+3, color2, c-3, b+3, color2, c-3, d-3, color2, a+3, d-3, color2, 4)
		@bigfont.draw("Paste", a+9, b+6, 5, 1.0, 1.0, 0xff000000)
		
		## Draw the copied content!! (jeez this is a lot of work)
		if @cursor == "paste" and @copy_data != false
			
			data_nodes = @copy_data[1]
			node_ids = @copy_data[2]
			data_levers = @copy_data[3]
			data_links = @copy_data[4]
			
			### Alright I've spent a lot of time trying to figure out how to paste a copied circuit onto a grid.
			### My intention was to paste the circuit so that it sits on the grid exactly the same way it originally did when copied.
			### However that's not how it works.
			### Currently it works by pasting the circuit so that the first node in the copied array is alligned perfectly with the grid regardless of its
			### original placement.
			### Then every other node is placed relative to that node.
			### This works perfectly when all nodes are placed within the grid, but it can cause some awkward behavior if you have nodes that are mixed
			### alligned with or without the grid. Especially if the first node is originally misaligned with the grid, you can imagine what would happen next.
			### 
			### Either way I decided to keep this "flawed" system this way because quite frankly I have no idea how to implement the intented system.
			### I know it's possible... but it's not necessary in my opinion. Just something to take note of.
			
			
			mid_x = data_nodes[0][0]
			mid_y = data_nodes[0][1]
			
			gridmid_x = (mid_x-@grid_size/2) % @grid_size
			gridmid_y = (mid_y-@grid_size/2) % @grid_size
			
			if @toggle_grid == true
				
				m_real_x1 = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
				m_real_y1 = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
				
				m_real_x = ((m_real_x1)*1.0/@grid_size).ceil*@grid_size - gridmid_x + @grid_size/2
				m_real_y = ((m_real_y1)*1.0/@grid_size).ceil*@grid_size - gridmid_y + @grid_size/2
				
			else
				
				m_real_x = (mouse_x-$window_width/2)/$camera_zoom+$camera_x
				m_real_y = (mouse_y-$window_height/2)/$camera_zoom+$camera_y
			end
			
			
			for i in 0..data_nodes.length-1
				
				nx = data_nodes[i][0] + m_real_x  ## Real
				ny = data_nodes[i][1] + m_real_y  ## Real
				
				if data_nodes[i][2] == 0
					color_new = 0x77ffffff
				else
					color_new = 0x77ff00ff
				end
				
				@circle_img.draw_rot(nx*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, ny*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 5, 0, 0.5, 0.5, 1.0*$camera_zoom, 1.0*$camera_zoom, color_new)
			end
			
			for i in 0..data_levers.length-1  ## [x_related, y_related, value_copy, id_copy]
				
				nx = data_levers[i][0] + m_real_x  ## Real
				ny = data_levers[i][1] + m_real_y  ## Real
				
				out_id = data_levers[i][3]
				
				if data_levers[i][2] == 0
					color_new = 0x77ffffff
				else
					color_new = 0x77ff00ff
				end
				
				col = 0x77777777
		
				self.draw_quad((nx-7)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (ny-7)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, (nx+7)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (ny-7)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, (nx+7)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (ny+7)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, (nx-7)*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (ny+7)*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, col, 5)
				self.draw_quad((nx-(7-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (ny-(7-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (nx+(7-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (ny-(7-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (nx+(7-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (ny+(7-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (nx-(7-2))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (ny+(7-2))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 5)
				
				out_x = data_nodes[out_id][0] + m_real_x
				out_y = data_nodes[out_id][1] + m_real_y
				
				self.draw_line(nx*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, ny*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, out_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, out_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 5)
				
			end
			
			for i in 0..data_links.length-1  ## [id_input_copy, id_output_copy, type_copy]
				
				input_id = data_links[i][0]
				output_id = data_links[i][1]
				type = data_links[i][2]
				
				if type == "repeater"
					if data_nodes[input_id][2] == 0
						color_new = 0x77ffffff
					else
						color_new = 0x77ff00ff
					end
				else
					if data_nodes[input_id][2] == 1
						color_new = 0x77ffffff
					else
						color_new = 0x77ff00ff
					end
				end
				
				in_x = data_nodes[input_id][0] + m_real_x
				in_y = data_nodes[input_id][1] + m_real_y
				
				out_x = data_nodes[output_id][0] + m_real_x
				out_y = data_nodes[output_id][1] + m_real_y
				
				reverse_dir = self.point_direction(out_x, out_y, in_x, in_y)
				
				if type == "repeater"
					
					## Main line
					self.draw_line(in_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, in_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, out_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, out_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 5)
					
					midline_x = (in_x + out_x)/2
					midline_y = (in_y + out_y)/2
					
					## Arrow head
					self.draw_line(midline_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, midline_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (midline_x + Gosu::offset_x(reverse_dir + 40, 10))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (midline_y + Gosu::offset_y(reverse_dir + 40, 10))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 5)
					self.draw_line(midline_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, midline_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (midline_x + Gosu::offset_x(reverse_dir - 40, 10))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (midline_y + Gosu::offset_y(reverse_dir - 40, 10))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 5)
					
				else
					
					new_in_x = in_x + Gosu::offset_x(reverse_dir+90, 3)
					new_in_y = in_y + Gosu::offset_y(reverse_dir+90, 3)
					
					new_out_x = out_x + Gosu::offset_x(reverse_dir+90, 3)
					new_out_y = out_y + Gosu::offset_y(reverse_dir+90, 3)
					
					self.draw_line(new_in_x*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, new_in_y*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, (new_out_x + Gosu::offset_x(reverse_dir, 10))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (new_out_y + Gosu::offset_y(reverse_dir, 10))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, color_new, 5)
					@circle_img.draw_rot((new_out_x + Gosu::offset_x(reverse_dir, 10))*$camera_zoom + $window_width/2 - $camera_x*$camera_zoom, (new_out_y + Gosu::offset_y(reverse_dir, 10))*$camera_zoom + $window_height/2 - $camera_y*$camera_zoom, 5, 0, 0.5, 0.5, 0.4*$camera_zoom, 0.4*$camera_zoom, color_new)
					
					
				end
				
			end
			
		end
		
	end
	
	def draw_bar(x1, y1, x2, y2, z, value, color1, color2, color3, border)
		# Value is supposed to be between 0..1
		# This function is made to draw a type of health-bar
		self.draw_quad(x1,y1,color1,x1+(x2-x1)*value,y1,color1,x1,y2,color1,x1+(x2-x1)*value,y2,color1,z+0.2)
		self.draw_quad(x1,y1,color2,x2,y1,color2,x1,y2,color2,x2,y2,color2,z+0.1)
		if border == true
			self.draw_quad(x1-1,y1-1,color3,x2+1,y1-1,color3,x1-1,y2+1,color3,x2+1,y2+1,color3,z)
		end
	end
	
	def needs_cursor?
		true
	end
	
	### Optimised point_in_rectangle. DOES NOT WORK IF SECOND POINT IS LESS THAN FIRST POINT!!!
	def point_in_rectangle(point_x, point_y, first_x, first_y, second_x, second_y)
		if point_x.between?(first_x, second_x) and point_y.between?(first_y, second_y)
			return true
		end
	end
	
	def point_direction(x1, y1, x2, y2)
		return ((Math::atan2(y2-y1, x2-x1) * (180/Math::PI)) + 450) % 360;
	end
	
end

# show the window
window = GameWindow.new
window.show