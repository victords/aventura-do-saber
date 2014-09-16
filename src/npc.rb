require 'minigl'
include AGL

class NPC < GameObject
	attr_reader :block
	
	def initialize x, y, id
		f = File.open("data/text/npc#{id}.txt")
		info = f.readline.chomp.split ','
		super x, y, info[0].to_i, info[1].to_i, "sprite_npc#{id}", Vector.new(info[2].to_i, info[3].to_i), 3, 2
		@facing_right = (info[4] == 'r')
		@state = 0
		@msgs = []
		@opts = []
		@switches = []
		
		states = f.read.split "\n\n"
		f.close
		states.each_with_index do |s, i|
			lines = s.split "\n"
			if lines[0][0] == '$'
				sw = lines[0].split[0][1..-1].to_i
				@state = i if G.switches.index sw
			end
			@msgs << (lines[0][0] == '$' ? lines[0][2..-1] : lines[0])
			break if i == states.length - 1
			@opts << lines[1..-2]
			@switches << lines[-1]
		end
		
		@block = Block.new @x + 5, @y + 5, @w - 10, @h - 5, false if @state < states.length - 1
		@writer = TextHelper.new G.font, 8
		@ellipsis = XSprite.new 0, 0, :ui_ellipsis
		@balloon = XSprite.new 0, 0, :ui_balloon
		@balloon_arrow = XSprite.new 0, 0, :ui_balloonArrow
		@talking_seq = [1, 2, 1, 0, 2, 1, 2, 0]
		@talking_seq_right = [4, 5, 4, 3, 5, 4, 5, 3]
	end
	
	def update
		@can_talk = bounds.intersects G.player.bounds
		if @can_talk and G.player.x > @x
			set_animation 3 unless @facing_right
			@facing_right = true
		elsif @can_talk
			set_animation 0 if @facing_right
			@facing_right = false
		end
		if @talking and not @can_talk
			set_animation (@facing_right ? 3 : 0)
			G.player.stop_interacting
			@balloon.fade_out
			@balloon_arrow.fade_out
		end
		if @can_talk and KB.key_pressed? Gosu::KbA
			if @talking
				@cur_page += 1
				if @cur_page == @pages.length
					@cur_page -= 1
					if require_item?
						UI.choose_item
					elsif @opts[@state].nil? or @opts[@state].empty?
						set_animation (@facing_right ? 3 : 0)
						G.player.stop_interacting
					else
						UI.choose_opt @opts[@state]
					end
				end
			else
				@talking = true
				@pages = @msgs[@state].split '/'
				@cur_page = 0
				G.player.interact_with self
			end
		end
		animate (@facing_right ? @talking_seq_right : @talking_seq), 8 if @talking
	end
	
	def require_item?
		return false unless @switches[@state]
		@switches[@state][0] == '!'
	end
	
	def send what
		s = @switches[@state].split[0]
		if s[0] == '+'
			option = s[1..-1].to_i
			if option == what; next_state
			else; G.scene.add_effect 0, 200, 100; end
		elsif s[0] == '!'
			item = s[1..-1].to_sym
			if item == what
				next_state
				G.player.use_item what, true
			else
				G.scene.add_effect 0, 200, 100
			end
		end
	end
	
	def next_state
		s = @switches[@state].split
		if s.length > 1
			sw = s[1][1..-1].to_i
			G.switches << sw
		end
		
		@state += 1
		@pages = @msgs[@state].split '/'
		@cur_page = 0
		G.scene.remove_obst @block if @state == @msgs.length - 1
	end
	
	def stop_interacting
		@talking = false
	end
	
	def draw map
		super map
		@ellipsis.x = @x - map.cam.x + @w / 2 - 25; @ellipsis.y = @y - map.cam.y - 45
		@balloon.x = @x - map.cam.x - 404; @balloon.y = @y - map.cam.y - 133
		@balloon_arrow.x = @x - map.cam.x - 34; @balloon_arrow.y = @y - map.cam.y - 35
		
		@ellipsis.draw
		if @talking
			@balloon.draw
			@balloon_arrow.draw
			@writer.write_breaking @pages[@cur_page], @x - map.cam.x - 374, @y - map.cam.y - 123, 380, :justified, 0, @balloon.alpha
		end
	end
end
