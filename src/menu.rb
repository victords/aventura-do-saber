require_relative 'global'
require_relative 'chart'
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
	attr_writer :text, :visible
	
	def initialize text, x, y, mode = :left, font = G.big_font, visible = true, width = nil
		@text = text
		@x = x
		@y = y
		@mode = mode
		@writer = TextHelper.new font
		@offset = (font == G.big_font ? 2 : 1)
		@visible = visible
		@width = width
	end
	
	def update; end
	
	def draw alpha
		return unless @visible
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
	attr_writer :visible
	
	def initialize x, y, img, visible = true, sprite_cols = nil, sprite_rows = nil, indices = nil, interval = nil
		super x, y, img, sprite_cols, sprite_rows
		@indices = indices
		@interval = interval
		@visible = visible
	end
	
	def update
		animate @indices, @interval if @indices
	end
	
	def set_pos x, y
		@x = x; @y = y
	end
	
	def draw alpha
		return unless @visible
		super nil, 1, 1, alpha
	end
end

class MenuButton < Button
	def initialize a, b, c, d, e, f = 0, g = 0, h = true, i = 0, j = 0, k = nil, l = nil, m = nil, &n
		super a, b, c, d, e, f, g, h, i, j, k, l, m, &n
		@sound = Res.sound :buttonClick
	end
	
	def click
		super
		@sound.play
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

class MainMenu < Menu
	def initialize
		@bg = Res.img :bg_menu
		@bgm = Res.song :track1
		
		@names = []
		@name_input = TextField.new(100, 160, G.big_font, :ui_textField, :ui_textCursor, nil, 20, 13, 12, true, "",
		                            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ") { |text|
		                              @name_button.visible = (text.length > 0)
		                            }
		@name_button = MenuButton.new(440, 555, G.font, "OK", :ui_btn1) {
			@continue = false
			@name = @name_input.text.downcase
			if @names.index @name
				@same_name.text = "Um jogo com nome '#{@name.capitalize}' já existe. Deseja continuar ou substituir?"
				go_to_screen 2
			else
				go_to_screen 3
			end
		}
		@name_button.visible = false
		@same_name = MenuText.new "", 240, 185, :justified, G.med_font, true, 320
		@continue = false
		
		@char = :marcus
		@char_name = MenuText.new "Marcus", 10, 536, :left, G.med_font
		@char_description = MenuText.new "Um simpático garoto de 10 anos.", 10, 572, :left, G.font
		@char_selection = MenuSprite.new 112, 87, :ui_selection, true, 2, 1, [0, 1], 10
		
		@game_type = 0
		@game_selection = MenuSprite.new 38, 98, :ui_selection2, true, 1, 2, [0, 1], 10
		
		@back_button = MenuButton.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 0 }
		name_screen_components = [
			MenuText.new("Qual é o seu nome?", 10, 5),
			@name_input, @name_button, @back_button
		]
		
		@score_label = MenuText.new "", 40, 110, :left, G.med_font
		@scenes_labels = []
		@c_answers_labels = []
		@w_answers_labels = []
		@chart = Chart.new 65, 320, 500, 200, 6
		score_choose_screen_components = [
			MenuText.new("Pontuações", 10, 5),
			MenuText.new("De quem você quer ver as pontuações?", 400, 120, :center, G.med_font),
			@back_button
		]
		score_screen_components = [
			MenuText.new("Pontuações", 10, 5), @score_label,
			MenuText.new("Matemática", 400, 150, :right, G.med_font),
			MenuText.new("L. Port.", 510, 150, :right, G.med_font),
			MenuText.new("Lógica", 620, 150, :right, G.med_font),
			MenuText.new("Tudo", 730, 150, :right, G.med_font),
			MenuText.new("Cenas visitadas", 40, 190, :left, G.med_font),
			MenuText.new("Respostas corretas", 40, 230, :left, G.med_font),
			MenuText.new("Respostas erradas", 40, 270, :left, G.med_font),
			MenuText.new("Evolução do número de respostas corretas", 315, 530, :center, G.font),
			MenuButton.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 5 },
			@chart
		]
		for i in 0..3
			b = MenuText.new "", 400 + i * 110, 190, :right, G.med_font
			score_screen_components << b
			@scenes_labels << b
			b = MenuText.new "", 400 + i * 110, 230, :right, G.med_font
			score_screen_components << b
			@c_answers_labels << b
			b = MenuText.new "", 400 + i * 110, 270, :right, G.med_font
			score_screen_components << b
			@w_answers_labels << b
		end
		
		Dir["data/save/*"].sort[1..10].each_with_index do |g, i|
			name = g.split('/')[-1]
			@names << name
			name_screen_components <<
				MenuButton.new(100 + (i % 2) * 300, 250 + (i / 2) * 40, G.med_font, name.capitalize, :ui_btn2){
					@name = name; @continue = true; go_to_screen 3
				}
			score_choose_screen_components <<
				MenuButton.new(100 + (i % 2) * 300, 200 + (i / 2) * 40, G.med_font, name.capitalize, :ui_btn2){
					f = File.open("data/save/#{name}")
					score = f.readline.to_i
					scenes = f.readline.split(',').map { |s| s.to_i }
					c_answers = []
					all_c_answers = f.readline.chomp.split('|', -1)
					all_c_answers.each { |a| c_answers << a.split(',').map { |s| s.to_i } }
					w_answers = f.readline.split(',').map { |s| s.to_i }
					f.close
					@score_label.text = "#{score} ponto#{score > 1 ? 's' : ''}"
					scenes.each_with_index { |s, i| @scenes_labels[i].text = s }
					c_answers.each_with_index { |s, i| @c_answers_labels[i].text = s.empty? ? 0 : s[-1] }
					w_answers.each_with_index { |s, i| @w_answers_labels[i].text = s }
					series = []
					series << Series.new("Matemática", 0xffff0000, c_answers[0]) unless c_answers[0].empty?
					series << Series.new("Língua Portuguesa", 0xff008000, c_answers[1]) unless c_answers[1].empty?
					series << Series.new("Lógica", 0xff0000ff, c_answers[2]) unless c_answers[2].empty?
					series << Series.new("Tudo", 0xffffff00, c_answers[3]) unless c_answers[3].empty?
					@chart.set_series(series)
					go_to_screen 6
				}
		end
		
		@info_icon = MenuSprite.new(40, 370, :icon_info, G.full_screen != G.win.fullscreen?)
		@info_text = MenuText.new("Reinicie o jogo para mudar o modo tela cheia.", 82, 370, :left, G.med_font, G.full_screen != G.win.fullscreen?)
		@chk1 = ToggleButton.new(40, 110, G.med_font, "Tela cheia", :ui_check, G.full_screen, 0, 0, false, 60, 10) { |c|
			G.set_option 0, c
			if c == G.win.fullscreen?
				@info_icon.visible = @info_text.visible = false
			else
				@info_icon.visible = @info_text.visible = true
			end
		}
		@chk2 = ToggleButton.new(40, 170, G.med_font, "Mostrar dicas", :ui_check, G.hints, 0, 0, false, 60, 10) { |c| G.set_option 1, c }
		@chk3 = ToggleButton.new(40, 230, G.med_font, "Tocar sons", :ui_check, G.sounds, 0, 0, false, 60, 10) { |c| G.set_option 2, c }
		@chk4 = ToggleButton.new(40, 290, G.med_font, "Tocar músicas", :ui_check, G.music, 0, 0, false, 60, 10) { |c| G.set_option 3, c }
		
		@screens = [
			MenuScreen.new([
				MenuPanel.new(-200, 163, 0, 163, :ui_menuComponent3)
			], [
				MenuButton.new(19, 193, G.font, "Jogar", :ui_btn1) { go_to_screen 1 },
				MenuButton.new(19, 253, G.font, "Pontuações", :ui_btn1) { go_to_screen 5 },
				MenuButton.new(19, 313, G.font, "Opções", :ui_btn1) { go_to_screen 7 },
				MenuButton.new(19, 373, G.font, "Sair", :ui_btn1) { G.quit_game },
				MenuText.new("Aventura do Saber", 400, 10, :center),
				MenuSprite.new(200, 100, :sprite_startScreen)
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], name_screen_components),
			MenuScreen.new([
				MenuPanel.new(210, -280, 210, 165, :ui_menuComponent4)
			], [
				MenuButton.new(245, 330, G.font, "Continuar", :ui_btn1) { @continue = true; go_to_screen 3 },
				MenuButton.new(405, 330, G.font, "Substituir", :ui_btn1) { go_to_screen 3 },
				MenuButton.new(325, 376, G.font, "Voltar", :ui_btn1) { @name_input.focus; go_to_screen 1 },
				@same_name
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], [
				MenuButton.new(440, 555, G.font, "OK", :ui_btn1) { go_to_screen 4 },
				MenuButton.new(600, 555, G.font, "Voltar", :ui_btn1) { @name_input.focus; go_to_screen 1 },
				MenuButton.new(122, 97, nil, nil, nil, 0, 0, 0, 0, 0, 212, 420) {
					@char = :marcus
					@char_name.text = "Marcus"
					@char_description.text = "Um simpático garoto de 10 anos."
					@char_selection.set_pos 112, 87
				},
				MenuButton.new(466, 97, nil, nil, nil, 0, 0, 0, 0, 0, 212, 420) {
					@char = :milena
					@char_name.text = "Milena"
					@char_description.text = "Uma adorável garota de 10 anos."
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
				MenuButton.new(440, 555, G.font, "OK", :ui_btn1) { G.start_game @game_type, @name, @char, @continue },
				MenuButton.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 3 },
				MenuButton.new(50, 110, nil, nil, nil, 0, 0, 0, 0, 0, 320, 180) { @game_type = 0; @game_selection.set_pos 38, 98 },
				MenuButton.new(430, 110, nil, nil, nil, 0, 0, 0, 0, 0, 320, 180) { @game_type = 1; @game_selection.set_pos 418, 98 },
				MenuButton.new(50, 330, nil, nil, nil, 0, 0, 0, 0, 0, 320, 180) { @game_type = 2; @game_selection.set_pos 38, 318 },
				MenuButton.new(430, 330, nil, nil, nil, 0, 0, 0, 0, 0, 320, 180) { @game_type = 3; @game_selection.set_pos 418, 318 },
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
				MenuPanel.new(800, 531, 570, 531, :ui_menuComponent2)
			], score_choose_screen_components),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(10, 600, 10, 90, :ui_menuComponent5)
			], score_screen_components),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(10, 600, 10, 90, :ui_menuComponent5)
			], [
				MenuText.new("Opções", 10, 5), @info_icon, @info_text, @chk1, @chk2, @chk3, @chk4,
				MenuButton.new(440, 555, G.font, "Salvar", :ui_btn1) { G.save_options; G.play_music @bgm; go_to_screen 0 },
				MenuButton.new(600, 555, G.font, "Cancelar", :ui_btn1) {
					@chk1.checked = G.full_screen
					@chk2.checked = G.hints
					@chk3.checked = G.sounds
					@chk4.checked = G.music
					go_to_screen 0
				}
			])
		]
		@cur_screen = 0
		G.play_music @bgm
	end
end

class SceneMenu < Menu
	def initialize game_type
		game_type =
			case game_type
			when 0 then :math
			when 1 then :port
			when 2 then :logic
			else        :all
			end
		@bg = Res.img "bg_#{game_type}Menu"
		
		@info_icon = MenuSprite.new(40, 370, :icon_info, G.full_screen != G.win.fullscreen?)
		@info_text = MenuText.new("Reinicie o jogo para mudar o modo tela cheia.", 82, 370, :left, G.med_font, G.full_screen != G.win.fullscreen?)
		@chk1 = ToggleButton.new(40, 110, G.med_font, "Tela cheia", :ui_check, G.full_screen, 0, 0, false, 60, 10) { |c|
			G.set_option 0, c
			if c == G.win.fullscreen?
				@info_icon.visible = @info_text.visible = false
			else
				@info_icon.visible = @info_text.visible = true
			end
		}
		@chk2 = ToggleButton.new(40, 170, G.med_font, "Mostrar dicas", :ui_check, G.hints, 0, 0, false, 60, 10) { |c| G.set_option 1, c }
		@chk3 = ToggleButton.new(40, 230, G.med_font, "Tocar sons", :ui_check, G.sounds, 0, 0, false, 60, 10) { |c| G.set_option 2, c }
		@chk4 = ToggleButton.new(40, 290, G.med_font, "Tocar músicas", :ui_check, G.music, 0, 0, false, 60, 10) { |c| G.set_option 3, c }
		
		@screens = [
			MenuScreen.new([
				MenuPanel.new(210, 600, 210, 165, :ui_menuComponent4)
			], [
				MenuButton.new(325, 230, G.font, "Continuar", :ui_btn1) { G.resume_game },
				MenuButton.new(325, 280, G.font, "Opções", :ui_btn1) { go_to_screen 1 },
				MenuButton.new(325, 330, G.font, "Sair", :ui_btn1) { go_to_screen 2 }
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(10, 600, 10, 90, :ui_menuComponent5)
			], [
				MenuText.new("Opções", 10, 5), @info_icon, @info_text, @chk1, @chk2, @chk3, @chk4,
				MenuButton.new(440, 555, G.font, "Salvar", :ui_btn1) { G.save_options; go_to_screen 0 },
				MenuButton.new(600, 555, G.font, "Cancelar", :ui_btn1) {
					@chk1.checked = G.full_screen
					@chk2.checked = G.hints
					@chk3.checked = G.sounds
					@chk4.checked = G.music
					go_to_screen 0
				}
			]),
			MenuScreen.new([
				MenuPanel.new(210, -280, 210, 165, :ui_menuComponent4)
			], [
				MenuButton.new(245, 360, G.font, "Sair", :ui_btn1) { G.back_to_menu },
				MenuButton.new(405, 360, G.font, "Cancelar", :ui_btn1) { go_to_screen 0 },
				MenuText.new("Tem certeza que deseja sair? Seu jogo será salvo automaticamente.", 240, 185, :justified, G.med_font, true, 320)
			])
		]
		@cur_screen = 0
	end
end
