require 'gosu'
require_relative 'lib/game_object'
require_relative 'lib/forms'
include AGL

class MyGame < Gosu::Window
	def initialize
		super 800, 600, false
		self.caption = "Game Test"
		
		Game.initialize self
		
		@man = GameObject.new 600, 400, 37, 115, :sprite2, Vector.new(-8, -5), 3, 2
		@man_indices = [0, 1, 0, 2, 0, 1, 0, 2, 3, 4, 3, 5, 3, 4, 3, 5]
		@man_interval = 9
		
		@stage = 1
		@bg = Res.img "scene#{@stage}".to_sym
		@obst = []
		@ramps = []
		File.open("data/stage/#{@stage}.txt") do |f|
			f.each_line do |l|
				if l[0] == "#" or l[0] == "$"
					a = l[2..-1].split ','
					@ramps << Ramp.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, l[0] == "#")
				else
					a = l.split ','
					@obst << Block.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, true)
				end
			end
		end
		
		@font = Gosu::Font.new self, "data/font/Ubuntu-L.ttf", 20
		@button = Button.new(600, 100, @font, "Restart", :btn1) {
			@man.speed.x = 0; @man.speed.y = 0
			@man.x = 600; @man.y = 400
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
		@man.move forces, @obst, @ramps
	end
	
	def draw
		@bg.draw 0, 0, 0
		@man.draw
		@button.draw
	end
end

game = MyGame.new
game.show
