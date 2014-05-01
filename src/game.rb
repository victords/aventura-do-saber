require 'gosu'
require './scene'
require './character'
require_relative 'lib/forms'
include AGL

class MyGame < Gosu::Window
	def initialize
		super 800, 600, false
		self.caption = "Aventura do Saber"
		
		Game.initialize self
		player = Character.new :marcus
		@scene = Scene.new 1, player, 1
		
		@font = Gosu::Font.new self, "data/font/Ubuntu-L.ttf", 20
		@button = Button.new(600, 100, @font, "Restart", :btn1) {
			@scene.reset
		}
	end
	
	def needs_cursor?
		true
	end
	
	def update
		KB.update
		Mouse.update
		
		@scene.update
		@button.update
	end
	
	def draw
		@scene.draw
		@button.draw
	end
end

game = MyGame.new
game.show
