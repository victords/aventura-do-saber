require_relative 'lib/game_object'
include AGL

class NPC < GameObject
	def initialize x, y, id
		case id
		when 1 then w = 30; h = 140; img_gap = Vector.new(-18, 0); rows = 1; cols = 1
		end
		
		super x, y, w, h, "npc#{id}", img_gap, rows, cols
	end
	
	def update scene
		move Vector.new(0, 0), scene.obsts, scene.ramps
	end
end
