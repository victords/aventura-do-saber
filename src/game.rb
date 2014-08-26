require_relative 'menu'
require_relative 'scene'
include AGL

class MyGame < Gosu::Window
	def initialize
		super 800, 600, false
		self.caption = "Aventura do Saber"
		
		Game.initialize self
		G.initialize
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

game = MyGame.new
game.show
