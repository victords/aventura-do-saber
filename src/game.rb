require 'gosu'
require_relative 'lib/game_object'
require_relative 'lib/forms'
include AGL

class MyGame < Gosu::Window
	def initialize
		super 800, 600, false
		self.caption = "Game Test"
		
		Game.initialize self
		
		@man = GameObject.new 200, 200, 37, 115, :sprite2, Vector.new(-8, -5), 3, 2
		@man_indices = [0, 1, 0, 2, 0, 1, 0, 2, 3, 4, 3, 5, 3, 4, 3, 5]
		@man_interval = 9
		
		@obst = [
			Block.new(100, 500, 600, 1, false),
			Block.new(99, 100, 1, 400, false),
			Block.new(500, 100, 1, 400, false)
		]
		
		@font = Gosu::Font.new self, "data/font/Ubuntu-L.ttf", 20
		@button = Button.new(600, 100, @font, "Restart", :btn1) {
			@man.speed.x = 0; @man.speed.y = 0
			@man.x = 200; @man.y = 200
		}
	end
	
	def needs_cursor?
		true
	end
	
	def update
		KB.update
		Mouse.update
		@button.update
		
		@man.animate @man_indices, @man_interval
		
		forces = Vector.new 0, 0
		forces.x -= 0.3 if KB.key_down? Gosu::KbLeft
		forces.x += 0.3 if KB.key_down? Gosu::KbRight
		forces.y -= 15 if KB.key_down? Gosu::KbUp and @man.bottom
		@man.move forces, @obst, []
	end
	
	def draw
		draw_quad 100, 100, 0xffffffff,
		          500, 100, 0xffffffff,
		          500, 500, 0xffffffff,
		          100, 500, 0xffffffff, 0
		@man.draw
		@button.draw
	end
end

game = MyGame.new
game.show
