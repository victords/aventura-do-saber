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
	def initialize text, x, y
		@text = text
		@x = x
		@y = y
	end
	
	def update; end
	
	def draw
		G.big_font.draw @text, @x - 2, @y - 2, 0, 1, 1, 0xff000000
		G.big_font.draw @text, @x, @y - 2, 0, 1, 1, 0xff000000
		G.big_font.draw @text, @x + 2, @y - 2, 0, 1, 1, 0xff000000
		G.big_font.draw @text, @x + 2, @y, 0, 1, 1, 0xff000000
		G.big_font.draw @text, @x + 2, @y + 2, 0, 1, 1, 0xff000000
		G.big_font.draw @text, @x, @y + 2, 0, 1, 1, 0xff000000
		G.big_font.draw @text, @x - 2, @y + 2, 0, 1, 1, 0xff000000
		G.big_font.draw @text, @x - 2, @y, 0, 1, 1, 0xff000000
		G.big_font.draw @text, @x, @y, 0, 1, 1, 0xffffffff
	end
end

class MenuScreen
	attr_reader :ready
	
	def initialize panels, components
		@panels = panels
		@components = components
		@ready = false
	end
	
	def update
		if @ready
			@components.each { |c| c.update }
		else
			@ready = true
			@panels.each do |p|
				p.update
				@ready = false unless p.ready
			end
		end
	end
	
	def go_back
		@panels.each { |p| p.go_back }
		@ready = false
	end
	
	def reset
		@panels.each { |p| p.reset }
		@ready = false
	end
	
	def draw
		@panels.each { |p| p.draw }
		@components.each { |c| c.draw } if @ready
	end
end

class Menu
	def initialize
		@bg = Res.img :bg_menu, true
		@screens = [
			MenuScreen.new([
				MenuPanel.new(-200, 163, 0, 163, :ui_menuComponent3)
			], [
				Button.new(19, 185, G.font, "Jogar", :ui_btn1) { go_to_screen 1 },
				Button.new(19, 245, G.font, "Pontuações", :ui_btn1) { puts "P" },
				Button.new(19, 305, G.font, "Opções", :ui_btn1) { puts "O" },
				Button.new(19, 365, G.font, "Sair", :ui_btn1) { G.win.close },
				MenuText.new("Aventura do Saber", 200, 10)
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], [
				Button.new(440, 555, G.font, "OK", :ui_btn1) { go_to_screen 2 },
				Button.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 0 },
				TextField.new(100, 260, G.big_font, :ui_textField, :ui_textCursor, "", 20, 13),
				MenuText.new("Qual é o seu nome?", 10, 10)
			]),
			MenuScreen.new([
				MenuPanel.new(-660, 0, 0, 0, :ui_menuComponent1),
				MenuPanel.new(800, 531, 409, 531, :ui_menuComponent2)
			], [
				Button.new(440, 555, G.font, "OK", :ui_btn1) { G.start_game },
				Button.new(600, 555, G.font, "Voltar", :ui_btn1) { go_to_screen 1 },
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
