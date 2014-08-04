require 'minigl'
include AGL

class NPC < GameObject
	def initialize x, y, id, state = 1
		case id
		when 1 then w = 45; h = 140; img_gap = Vector.new(-3, 0)
		end
		
		super x, y, w, h, "sprite_npc#{id}", img_gap, 3, 1
		
		@message = G.texts["npc#{id}_#{state}"]
		@writer = TextHelper.new G.font, 8
		@ellipsis = Res.img :ui_ellipsis
		@balloon = Res.img :ui_balloon
		@balloon_arrow = Res.img :ui_balloonArrow
		@talking_seq = [1, 2, 1, 0, 2, 1, 2, 0]
		@alpha = 0
	end
	
	def update scene
		move Vector.new(0, 0), scene.obsts, scene.ramps
		@can_talk = (@left == G.player.char or @right == G.player.char)
		if @talking and not @can_talk
			@talking = false
			@leaving = true
			set_animation 0
			G.player.talking = false
		end
		if @can_talk and KB.key_pressed? Gosu::KbA
			if @talking
				@talking = false
				set_animation 0
				G.player.talking = false
				@alpha = 0
			else
				@talking = true
				G.player.talking = true
				@alpha = 0
			end
		end
		animate @talking_seq, 8 if @talking
		@alpha += 17 if @alpha < 255 and (@can_talk or @talking)
		@alpha -= 17 if @alpha > 0 and not @can_talk and not @talking
		@leaving = false if @alpha == 0
	end
	
	def draw map
		super map
		if @talking or @leaving
			color = (@alpha << 24) | 0xffffff
			@balloon.draw @x - 404, @y - 133, 0, 1, 1, color
			@balloon_arrow.draw @x - 34, @y - 35, 0, 1, 1, color
			@writer.write_breaking @message, @x - 374, @y - 123, 380, :justified, 0, @alpha
		elsif @alpha > 0
			color = (@alpha << 24) | 0xffffff
			@ellipsis.draw @x + @w / 2 - 25, @y - 45, 0, 1, 1, color
		end
	end
end
