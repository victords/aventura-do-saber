require_relative 'lib/game_object'
include AGL

class Item < GameObject
	attr_reader :type, :dead
	
	def initialize x, y, type
		@type = type
		
		super x, y, 30, 30, type, Vector.new(0, 0)
	end
	
	def update scene
		forces = Vector.new(0, 0)
		move forces, scene.obsts, scene.ramps
		
		if bounds.intersects scene.character.bounds
			@dead = true
		end
	end
end
