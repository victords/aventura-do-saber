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
	def initialize text, x, y, mode = :left, font = G.big_font
		@text = text
		@x = x
		@y = y
		@mode = mode
		@writer = TextHelper.new font
		@offset = (font == G.big_font ? 2 : 1)
	end
	
	def update; end
	def set_text text
		@text = text
	end
	
	def draw alpha
		@writer.write_line @text, @x - @offset, @y - @offset, @mode, 0, alpha
		@writer.write_line @text, @x, @y - @offset, @mode, 0, alpha
		@writer.write_line @text, @x + @offset, @y - @offset, @mode, 0, alpha
		@writer.write_line @text, @x + @offset, @y, @mode, 0, alpha
		@writer.write_line @text, @x + @offset, @y + @offset, @mode, 0, alpha
		@writer.write_line @text, @x, @y + @offset, @mode, 0, alpha
		@writer.write_line @text, @x - @offset, @y + @offset, @mode, 0, alpha
		@writer.write_line @text, @x - @offset, @y, @mode, 0, alpha
		@writer.write_line @text, @x, @y, @mode, 0xffffff, alpha
	end
end

class MenuSprite < Sprite
	def initialize x, y, img, sprite_cols = nil, sprite_rows = nil, indices = nil, interval = nil
		super x, y, img, sprite_cols, sprite_rows
		@indices = indices
		@interval = interval
	end
	
	def update
		animate @indices, @interval if @indices
	end
	
	def set_pos x, y
		@x = x; @y = y
	end
	
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
			Button.new(440, 555, G.font, "OK", :ui_btn1) { @name = @name_input.text; go_to_screen 2 },
			Button.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 0 },
			Button.new(440, 555, G.font, "OK", :ui_btn1) { G.start_game @char, @name },
			Button.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 1 },
			Button.new(122, 97, nil, nil, nil, 0, 0, 0, 0, 212, 420) {
				@char = :marcus
				@char_name.set_text "Marcus"
				@char_description.set_text "Um simpático garoto de 10 anos."
				@selection.set_pos 112, 87
			},
			Button.new(466, 97, nil, nil, nil, 0, 0, 0, 0, 212, 420) {
				@char = :milena
				@char_name.set_text "Milena"
				@char_description.set_text "Uma adorável garota de 10 anos."
				@selection.set_pos 456, 87
			}
		]
		
		@char = :marcus
		@char_name = MenuText.new "Marcus", 10, 536, :left, G.med_font
		@char_description = MenuText.new "Um simpático garoto de 10 anos.", 10, 572, :left, G.font
		@selection = MenuSprite.new 112, 87, :ui_selection, 2, 1, [0,1], 10
		
		@name_input = TextField.new 100, 160, G.big_font, :ui_textField, :ui_textCursor, 20, 13, 20, true
		name_screen_components = [
			@buttons[4], @buttons[5], @name_input,
			MenuText.new("Qual é o seu nome?", 10, 5)
		]
		games = Dir["data/save/*"]
		games.each_with_index do |g, i|
			name = g.split('/')[-1]
			name_screen_components << Button.new(200, 250 + i * 40, G.med_font, name, :ui_btn2) { @name = name; go_to_screen 2 }
		end
		
		@screens = [
			MenuScreen.new([
				MenuPanel.new(-200, 163, 0, 163, :ui_menuComponent3)
			], [
				@buttons[0], @buttons[1], @buttons[2], @buttons[3],
				MenuText.new("Aventura do Saber", 400, 10, :center)
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], name_screen_components),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], [
				@buttons[6], @buttons[7], @buttons[8], @buttons[9],
				MenuText.new("Escolha seu personagem!", 10, 5),
				MenuSprite.new(132, 107, :sprite_marcusMenu),
				MenuSprite.new(495, 112, :sprite_milenaMenu),
				@selection, @char_name, @char_description
			])
		]
		@cur_screen = 0
	end
	
	def update
		@screens[@cur_screen].update
		if @changing and @screens[@cur_screen].ready
			@changing = false
			@cur_screen = @next_screen
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
