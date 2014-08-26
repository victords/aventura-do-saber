require 'minigl'
include AGL

class NPC < GameObject
	attr_reader :block
	
	def initialize x, y, id, state
		f = File.open("data/text/npc#{id}.txt")
		info = f.readline.chomp.split ','
		super x, y, info[0].to_i, info[1].to_i, "sprite_npc#{id}", Vector.new(info[2].to_i, info[3].to_i), 3, 1
		@state = state
		@msgs = []
		@opts = []
		@switches = []
		states = f.read.split "\n\n"
		states.each_with_index do |s, i|
			lines = s.split "\n"
			@msgs << lines[0]
			break if i == states.length - 1
			@opts << []
			lines[1..-2].each_with_index do |l, j|
				@opts[i] << Button.new(200, 600 + (j - lines.length + 2) * 40, G.med_font, l, nil, 0, 0, false, 5, 5, 400, 40, j+1){ |o| send o }
			end
			@switches << lines[-1]
		end
		
		@block = Block.new @x + 5, @y + 5, @w - 10, @h - 5, false
		@writer = TextHelper.new G.font, 8
		@ellipsis = Res.img :ui_ellipsis
		@balloon = Res.img :ui_balloon
		@balloon_arrow = Res.img :ui_balloonArrow
		@panel = Res.img :ui_panel3
		@talking_seq = [1, 2, 1, 0, 2, 1, 2, 0]
		@alpha = 0
	end
	
	def update
		@can_talk = bounds.intersects G.player.bounds
		if @talking and not @can_talk
			@talking = false
			@leaving = true
			set_animation 0
			G.player.stop_talking
		end
		if @can_talk and KB.key_pressed? Gosu::KbA
			if @talking
				if @opts[@state].empty?
					@talking = false
					set_animation 0
					G.player.stop_talking
					@alpha = 0
				else
					@show_opts = true
				end
			else
				@talking = true
				G.player.talk_to self
				@alpha = 0
			end
		end
		if @show_opts
			@opts[@state].each { |o| o.update }
		end
		animate @talking_seq, 8 if @talking
		@alpha += 17 if @alpha < 255 and (@can_talk or @talking)
		@alpha -= 17 if @alpha > 0 and not @can_talk and not @talking
		@leaving = false if @alpha == 0
	end
	
	def require_item?
		@switches[@state][0] == '!'
	end
	
	def send what
		s = @switches[@state]
		if s[0] == '+'
			option = s[1..-1].to_i
			next_state if option == what
		elsif s[0] == '!'
			item = s[1..-1].to_sym
			if item == what
				next_state
				G.player.use_item what
			end
		end
	end
	
	def next_state
		@state += 1
		G.scene.remove_obst @block if @state == @msgs.length - 1
		@show_opts = false
	end
	
	def draw map
		super map
		if @talking or @leaving
			color = (@alpha << 24) | 0xffffff
			@balloon.draw @x - 404, @y - 133, 0, 1, 1, color
			@balloon_arrow.draw @x - 34, @y - 35, 0, 1, 1, color
			@writer.write_breaking @msgs[@state], @x - 374, @y - 123, 380, :justified, 0, @alpha
		elsif @alpha > 0
			color = (@alpha << 24) | 0xffffff
			@ellipsis.draw @x + @w / 2 - 25, @y - 45, 0, 1, 1, color
		end
		if @show_opts
			@panel.draw 200, 588 - (@opts[@state].length) * 40, 0
			@opts[@state].each { |b| b.draw }
		end
	end
end
