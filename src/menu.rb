require_relative 'global'
include AGL

class MenuPanel
	attr_reader :ready
	
	def initialize x, y, aim_x, aim_y, img
		@x = @start_x = x
		@y = @start_y = y
		@aim_x = @start_aim_x = aim_x
		@aim_y = @start_aim_y = aim_y
		@img = Res.img img
		@speed_x = (@aim_x - @x) / 8.0
		@speed_y = (@aim_y - @y) / 8.0
		@ready = false
	end
	
	def update
		unless @ready
			@x += @speed_x
			@y += @speed_y
			dist_x = @aim_x - @x
			dist_y = @aim_y - @y
			if dist_x.round == 0 and dist_y.round == 0
				@x = @aim_x
				@y = @aim_y
				@ready = true
			else
				@speed_x = dist_x / 8.0
				@speed_y = dist_y / 8.0
			end
		end
	end
	
	def go_back
		@aim_x = @start_x
		@aim_y = @start_y
		@speed_x = (@aim_x - @x) / 8.0
		@speed_y = (@aim_y - @y) / 8.0
		@ready = false
	end
	
	def reset
		@x = @start_x
		@y = @start_y
		@aim_x = @start_aim_x
		@aim_y = @start_aim_y
		@speed_x = (@aim_x - @x) / 8.0
		@speed_y = (@aim_y - @y) / 8.0
		@ready = false
	end
	
	def draw
		@img.draw @x, @y, 0
	end
end

class MenuText
	def initialize text, x, y, mode = :left
		@text = text
		@x = x
		@y = y
		@mode = mode
		@writer = TextHelper.new G.big_font
	end
	
	def update; end
	
	def draw alpha
		@writer.write_line @text, @x - 2, @y - 2, @mode, 0, alpha
		@writer.write_line @text, @x, @y - 2, @mode, 0, alpha
		@writer.write_line @text, @x + 2, @y - 2, @mode, 0, alpha
		@writer.write_line @text, @x + 2, @y, @mode, 0, alpha
		@writer.write_line @text, @x + 2, @y + 2, @mode, 0, alpha
		@writer.write_line @text, @x, @y + 2, @mode, 0, alpha
		@writer.write_line @text, @x - 2, @y + 2, @mode, 0, alpha
		@writer.write_line @text, @x - 2, @y, @mode, 0, alpha
		@writer.write_line @text, @x, @y, @mode, 0xffffff, alpha
	end
end

class Selector < Sprite
	attr_reader :pos_index
	
	def initialize positions, vertical, img
		super positions[0].x, positions[0].y, img, 2, 1
		@positions = positions
		@pos_index = 0
		@vertical = vertical
		@indices = [0, 1]
		@interval = 10
	end
	
	def update
		if @vertical
			if KB.key_pressed? Gosu::KbDown or KB.key_held? Gosu::KbDown
				@pos_index = (@pos_index + 1) % @positions.length
			elsif KB.key_pressed? Gosu::KbUp or KB.key_held? Gosu::KbUp
				@pos_index = (@pos_index - 1) % @positions.length
			end
		else
			if KB.key_pressed? Gosu::KbRight or KB.key_held? Gosu::KbRight
				@pos_index = (@pos_index + 1) % @positions.length
			elsif KB.key_pressed? Gosu::KbLeft or KB.key_held? Gosu::KbLeft
				@pos_index = (@pos_index - 1) % @positions.length
			end
		end
		@x = @positions[@pos_index].x
		@y = @positions[@pos_index].y
		animate @indices, @interval
	end
	
	def set_index index
		@pos_index = index
		@x = @positions[@pos_index].x
		@y = @positions[@pos_index].y
	end
	
	def draw alpha
		return if alpha < 0xff
		super nil
	end
end

class MenuSprite < Sprite
	def update; end
	
	def draw alpha
		super nil, 1, 1, alpha
	end
end

class MenuScreen
	attr_reader :ready
	
	def initialize panels, components
		@panels = panels
		@components = components
		@ready = false
		@fading = false
		@alpha = 0
	end
	
	def update
		if @ready
			@components.each { |c| c.update }
			if @fading
				@alpha += 17
				@fading = false if @alpha == 255
			end
		else
			@ready = true
			@panels.each do |p|
				p.update
				@ready = false unless p.ready
			end
			@fading = true if @ready
		end
	end
	
	def go_back
		@panels.each { |p| p.go_back }
		@ready = false
	end
	
	def reset
		@panels.each { |p| p.reset }
		@ready = false
		@fading = false
		@alpha = 0
	end
	
	def draw
		@panels.each { |p| p.draw }
		@components.each { |c| c.draw @alpha } if @ready
	end
end

class Menu
	def initialize
		@bg = Res.img :bg_menu, true
		@buttons = [
			Button.new(19, 193, G.font, "Jogar", :ui_btn1) { go_to_screen 1 },
			Button.new(19, 253, G.font, "Pontuações", :ui_btn1) { puts "P" },
			Button.new(19, 313, G.font, "Opções", :ui_btn1) { puts "O" },
			Button.new(19, 373, G.font, "Sair", :ui_btn1) { G.win.close },
			Button.new(440, 555, G.font, "OK", :ui_btn1) { go_to_screen 2 },
			Button.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 0 },
			Button.new(440, 555, G.font, "OK", :ui_btn1) { G.start_game @char_selector.pos_index },
			Button.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 1 },
			Button.new(122, 97, nil, nil, nil, 0, 0, 0, 0, 212, 420) { @char_selector.set_index 0 },
			Button.new(466, 97, nil, nil, nil, 0, 0, 0, 0, 212, 420) { @char_selector.set_index 1 }
		]
		@selectors = [
			Selector.new([Vector.new(17, 191), Vector.new(17, 251), Vector.new(17, 311), Vector.new(17, 371)], true, :ui_btnSelection),
			Selector.new([Vector.new(438, 553), Vector.new(598, 553)], false, :ui_btnSelection),
			Selector.new([Vector.new(438, 553), Vector.new(598, 553)], false, :ui_btnSelection)
		]
		@char_selector = Selector.new([Vector.new(112, 87), Vector.new(456, 87)], false, :ui_selection)
		@screens = [
			MenuScreen.new([
				MenuPanel.new(-200, 163, 0, 163, :ui_menuComponent3)
			], [
				@buttons[0], @buttons[1], @buttons[2], @buttons[3], @selectors[0],
				MenuText.new("Aventura do Saber", 400, 10, :center)
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], [
				@buttons[4], @buttons[5], @selectors[1],
				TextField.new(100, 260, G.big_font, :ui_textField, :ui_textCursor, 20, 13, 20, true),
				MenuText.new("Qual é o seu nome?", 10, 5)
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], [
				@buttons[6], @buttons[7], @buttons[8], @buttons[9], @selectors[2],
				MenuText.new("Escolha seu personagem!", 10, 5),
				MenuSprite.new(132, 107, :sprite_marcusMenu),
				MenuSprite.new(495, 112, :sprite_milenaMenu),
				@char_selector
			])
		]
		@cur_screen = 0
	end
	
	def update
		@screens[@cur_screen].update
		if @changing
			if @screens[@cur_screen].ready
				@changing = false
				@cur_screen = @next_screen
			end
		elsif KB.key_pressed? Gosu::KbReturn
			offset = 
				case @cur_screen
				when 0 then 0
				when 1 then 4
				when 2 then 6
				end
			@buttons[offset + @selectors[@cur_screen].pos_index].click
		elsif KB.key_pressed? Gosu::KbTab
			# alternar foco dos selectors...
		end
	end
	
	def go_to_screen index
		@screens[@cur_screen].go_back
		@screens[index].reset
		@next_screen = index
		@changing = true
	end
	
	def draw
		@bg.draw 0, 0, 0
		@screens[@cur_screen].draw
	end
end
