# This example demonstrates the use of the TextInput functionality.
# One can tab through, or click into the text fields and change it's contents.

# At its most basic form, you only need to create a new TextInput instance and
# set the text_input attribute of your window to it. Until you set this
# attribute to nil again, the TextInput object will build a text that can be
# accessed via TextInput#text.

# The TextInput object also maintains the position of the caret as the index
# of the character that it's left to via the caret_pos attribute. Furthermore,
# if there is a selection, the selection_start attribute yields its beginning,
# using the same indexing scheme. If there is no selection, selection_start
# is equal to caret_pos.

# A TextInput object is purely abstract, though; drawing the input field is left
# to the user. In this case, we are subclassing TextInput to add this code.
# As with most of Gosu, how this is handled is completely left open; the scheme
# presented here is not mandatory! Gosu only aims to provide enough code for
# games (or intermediate UI toolkits) to be built upon it.

require 'rubygems'
require 'gosu'

class TextField < Gosu::TextInput
  # Some constants that define our appearance.
  INACTIVE_COLOR  = 0x00000000 # 0xcc666666
  ACTIVE_COLOR    = 0x00000000 # 0xccff6666
  SELECTION_COLOR = 0xccFF541C # 0xcc0000ff
  CARET_COLOR     = 0xff000000 # 0xffffffff
  TEXT_COLOR      = 0xff000000
  PADDING = 5
  
  attr_reader :x, :y
  
  def initialize(window, font, x, y, z)
    # TextInput's constructor doesn't expect any arguments.
    super()
    
    @window, @font, @x, @y, @z = window, font, x, y, z
    
    # Start with a self-explanatory text in each field.
    self.text = "Click to change text"
  end
  
  # Example filter method. You can truncate the text to employ a length limit (watch out
  # with Ruby 1.8 and UTF-8!), limit the text to certain characters etc.
  
  #def filter text
  #  text.upcase
  #end
  
  def draw
    # Depending on whether this is the currently selected input or not, change the
    # background's color.
    if @window.text_input == self then
      background_color = ACTIVE_COLOR
    else
      background_color = INACTIVE_COLOR
    end
    @window.draw_quad(x - PADDING,         y - PADDING,          background_color,
                      x + width + PADDING, y - PADDING,          background_color,
                      x - PADDING,         y + height + PADDING, background_color,
                      x + width + PADDING, y + height + PADDING, background_color, @z)
    
    # Calculate the position of the caret and the selection start.
    pos_x = x + @font.text_width(self.text[0...self.caret_pos])
    sel_x = x + @font.text_width(self.text[0...self.selection_start])
    
    # Draw the selection background, if any; if not, sel_x and pos_x will be
    # the same value, making this quad empty.
    @window.draw_quad(sel_x, y,          SELECTION_COLOR,
                      pos_x, y,          SELECTION_COLOR,
                      sel_x, y + height, SELECTION_COLOR,
                      pos_x, y + height, SELECTION_COLOR, @z)

    # Draw the caret; again, only if this is the currently selected field.
    if @window.text_input == self then
      @window.draw_line(pos_x, y,          CARET_COLOR,
                        pos_x, y + height, CARET_COLOR, @z)
    end

    # Finally, draw the text itself!
    @font.draw(self.text, x, y, @z, 1.0, 1.0, TEXT_COLOR)
  end

  # This text field grows with the text that's being entered.
  # (Usually one would use clip_to and scroll around on the text field.)
  def width
	@font.text_width(self.text)
  end
  
  def update_stuff(font, x, y, z)
	@font = font
	@x = x
	@y = y
	@z = z
  end
  
  def height
    @font.height
  end

  # Hit-test for selecting a text field with the mouse.
  def under_point?(mouse_x, mouse_y)
    mouse_x > x - PADDING and mouse_x < x + width + PADDING and
      mouse_y > y - PADDING and mouse_y < y + height + PADDING
  end
  
  # Tries to move the caret to the position specifies by mouse_x
  def move_caret(mouse_x)
    # Test character by character
    1.upto(self.text.length) do |i|
      if mouse_x < x + @font.text_width(text[0...i]) then
        self.caret_pos = self.selection_start = i - 1;
        return
      end
    end
    # Default case: user must have clicked the right edge
    self.caret_pos = self.selection_start = self.text.length
  end
end