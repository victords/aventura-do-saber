require 'minigl'
include AGL

class Item < GameObject
	attr_reader :type, :dead, :icon
	
	def initialize x, y, type, switch = nil
		super x, y, 30, 30, "sprite_#{type}", Vector.new(0, 0)
		@type = type
		@icon = Res.img "icon_#{type}"
		@switch = switch
	end
	
	def update
		forces = Vector.new(0, 0)
		move forces, G.scene.obsts, G.scene.ramps
		
		if bounds.intersects G.player.bounds
			G.player.add_item self
			G.add_item_switch @switch if @switch
			@dead = true
		end
	end
	
#	def use
#		puts "Usando #{@type}"
#	end
end
