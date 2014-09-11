require_relative 'menu'
require_relative 'scene'
include AGL

class MyGame < Gosu::Window
	def initialize full_screen, first = true
		super 800, 600, full_screen
		self.caption = "Aventura do Saber"
		
		Game.initialize self
		G.initialize first
	end
	
	def needs_cursor?
		true
	end
	
	def update
		KB.update
		Mouse.update
		
		if G.state == :menu
			G.menu.update
		elsif
			G.scene.update
		end
		
		close if KB.key_pressed? Gosu::KbEscape
	end
	
	def draw
		if G.state == :menu
			G.menu.draw
		elsif
			G.scene.draw
		end
	end
end

fs = false
game = MyGame.new fs
game.show
until G.quit
	game = MyGame.new G.full_screen, false
	game.show
end

