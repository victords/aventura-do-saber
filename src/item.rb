require 'minigl'
include AGL

class Item < GameObject
	attr_reader :type, :dead, :icon
	
	def initialize x, y, type
		super x, y, 30, 30, "sprite_#{type}", Vector.new(0, 0)
		@type = type
		@icon = Res.img "icon_#{type}"
	end
	
	def update scene
		forces = Vector.new(0, 0)
		move forces, scene.obsts, scene.ramps
		
		if bounds.intersects G.player.char.bounds
			G.player.add_item self
			@dead = true
		end
	end
end
