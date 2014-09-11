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
	def initialize text, x, y, mode = :left, font = G.big_font, width = nil
		@text = text
		@x = x
		@y = y
		@mode = mode
		@writer = TextHelper.new font
		@offset = (font == G.big_font ? 2 : 1)
		@width = width
	end
	
	def update; end
	
	def set_text text
		@text = text
	end
	
	def draw alpha
		if @mode == :justified
			@writer.write_breaking @text, @x, @y, @width, @mode, 0, alpha
		else
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
	def initialize first
		@bg = Res.img :bg_menu, true
		
		@names = []
		@name_input = TextField.new(100, 160, G.big_font, :ui_textField, :ui_textCursor, nil, 20, 13, 12, true, "",
		                            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ") { |text|
		                              @name_button.visible = (text.length > 0)
		                            }
		@name_button = Button.new(440, 555, G.font, "OK", :ui_btn1) {
			@name = @name_input.text.downcase
			if @names.index @name
				@same_name.set_text "Um jogo com nome '#{@name.capitalize}' já existe. Deseja continuar ou substituir?"
				go_to_screen 2
			else
				go_to_screen 3
			end
		}
		@name_button.visible = false
		@same_name = MenuText.new "", 240, 185, :justified, G.med_font, 320
		@continue = false
		
		@char = :marcus
		@char_name = MenuText.new "Marcus", 10, 536, :left, G.med_font
		@char_description = MenuText.new "Um simpático garoto de 10 anos.", 10, 572, :left, G.font
		@char_selection = MenuSprite.new 112, 87, :ui_selection, 2, 1, [0, 1], 10
		
		@game_type = :math
		@game_selection = MenuSprite.new 38, 98, :ui_selection2, 1, 2, [0, 1], 10
		
		name_screen_components = [
			Button.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 0 },
			MenuText.new("Qual é o seu nome?", 10, 5),
			@name_input, @name_button
		]
		
		Dir["data/save/*"].sort[0..9].each_with_index do |g, i|
			name = g.split('/')[-1]
			@names << name
			name_screen_components <<
				Button.new(100 + (i % 2) * 300, 250 + (i / 2) * 40, G.med_font, name.capitalize, :ui_btn2){
					@name = name; @continue = true; go_to_screen 3
				}
		end
		
		@screens = [
			MenuScreen.new([
				MenuPanel.new(-200, 163, 0, 163, :ui_menuComponent3)
			], [
				Button.new(19, 193, G.font, "Jogar", :ui_btn1) { go_to_screen 1 },
				Button.new(19, 253, G.font, "Pontuações", :ui_btn1) { puts "P" },
				Button.new(19, 313, G.font, "Opções", :ui_btn1) { go_to_screen 5 },
				Button.new(19, 373, G.font, "Sair", :ui_btn1) { G.quit_game },
				MenuText.new("Aventura do Saber", 400, 10, :center)
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], name_screen_components),
			MenuScreen.new([
				MenuPanel.new(210, -280, 210, 165, :ui_menuComponent4)
			], [
				Button.new(245, 330, G.font, "Continuar", :ui_btn1) { @continue = true; go_to_screen 3 },
				Button.new(405, 330, G.font, "Substituir", :ui_btn1) { go_to_screen 3 },
				Button.new(325, 376, G.font, "Voltar", :ui_btn1) { @name_input.focus; go_to_screen 1 },
				@same_name
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], [
				Button.new(440, 555, G.font, "OK", :ui_btn1) { go_to_screen 4 },
				Button.new(600, 555, G.font, "Voltar", :ui_btn1) { @name_input.focus; go_to_screen 1 },
				Button.new(122, 97, nil, nil, nil, 0, 0, 0, 0, 0, 212, 420) {
					@char = :marcus
					@char_name.set_text "Marcus"
					@char_description.set_text "Um simpático garoto de 10 anos."
					@char_selection.set_pos 112, 87
				},
				Button.new(466, 97, nil, nil, nil, 0, 0, 0, 0, 0, 212, 420) {
					@char = :milena
					@char_name.set_text "Milena"
					@char_description.set_text "Uma adorável garota de 10 anos."
					@char_selection.set_pos 456, 87
				},
				MenuText.new("Escolha seu personagem!", 10, 5),
				MenuSprite.new(132, 107, :sprite_marcusMenu),
				MenuSprite.new(495, 112, :sprite_milenaMenu),
				@char_selection, @char_name, @char_description
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], [
				Button.new(440, 555, G.font, "OK", :ui_btn1) { G.start_game @game_type, @name, @char, @continue },
				Button.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 3 },
				Button.new(50, 110, nil, nil, nil, 0, 0, 0, 0, 0, 320, 180) { @game_type = :math; @game_selection.set_pos 38, 98 },
				Button.new(430, 110, nil, nil, nil, 0, 0, 0, 0, 0, 320, 180) { @game_type = :port; @game_selection.set_pos 418, 98 },
				Button.new(50, 330, nil, nil, nil, 0, 0, 0, 0, 0, 320, 180) { @game_type = :logic; @game_selection.set_pos 38, 318 },
				Button.new(430, 330, nil, nil, nil, 0, 0, 0, 0, 0, 320, 180) { @game_type = :all; @game_selection.set_pos 418, 318 },
				MenuSprite.new(50, 110, :sprite_math),
				MenuSprite.new(430, 110, :sprite_port),
				MenuSprite.new(50, 330, :sprite_logic),
				MenuSprite.new(430, 330, :sprite_all),
				MenuText.new("O que você quer praticar?", 10, 5),
				MenuText.new("Matemática", 60, 248, :left, G.med_font),
				MenuText.new("Língua Portuguesa", 440, 248, :left, G.med_font),
				MenuText.new("Lógica", 60, 468, :left, G.med_font),
				MenuText.new("Tudo isso!", 440, 468, :left, G.med_font),
				@game_selection
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(10, 600, 10, 120, :ui_menuComponent5)
			], [
				MenuText.new("Opções", 10, 5),
				ToggleButton.new(40, 140, G.med_font, "Tela cheia", :ui_check, G.full_screen, 0, 0, false, 60, 10) { |c| G.set_full_screen c },
				Button.new(440, 555, G.font, "OK", :ui_btn1) { puts "salvar opções..." },
				Button.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 0 }
			])
		]
		@cur_screen = first ? 0 : 5
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
