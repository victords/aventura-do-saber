require_relative 'menu'
require_relative 'scene'
require_relative 'character'
include AGL

class MyGame < Gosu::Window
	def initialize
		super 800, 600, false
		self.caption = "Aventura do Saber"
		
		Game.initialize self
		G.initialize
		
		@menu = Menu.new
#		player = Character.new :marcus
#		@scene = Scene.new 1, player, 1
#		
#		@font = Gosu::Font.new self, "data/font/Ubuntu-L.ttf", 20
#		@button = Button.new(600, 100, @font, "Restart", :btn1) {
#			@scene.reset
#		}
	end
	
	def needs_cursor?
		true
	end
	
	def update
		KB.update
		Mouse.update
		
		@menu.update
#		@scene.update
#		@button.update
	end
	
	def draw
		@menu.draw
#		@scene.draw
#		@button.draw
	end
end

game = MyGame.new
game.show
