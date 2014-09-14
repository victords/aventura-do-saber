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
			@opts << []
			lines[1..-2].each_with_index do |l, j|
				@opts[i] << Button.new(216, 600 + (j - lines.length + 2) * 40, G.med_font, l, :ui_btn3, 0, 0, false, 5, 5, 0, 0, j+1){ |o| send o }
			end
			@switches << lines[-1]
		end
		
		@block = Block.new @x + 5, @y + 5, @w - 10, @h - 5, false if @state < states.length - 1
		@writer = TextHelper.new G.font, 8
		@ellipsis = Res.img :ui_ellipsis
		@balloon = Res.img :ui_balloon
		@balloon_arrow = Res.img :ui_balloonArrow
		@panel = Res.img :ui_panel3
		@talking_seq = [1, 2, 1, 0, 2, 1, 2, 0]
		@talking_seq_right = [4, 5, 4, 3, 5, 4, 5, 3]
		@alpha = 0
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
			@talking = false
			@leaving = true
			set_animation (@facing_right ? 3 : 0)
			G.player.stop_talking
		end
		if @can_talk and KB.key_pressed? Gosu::KbA
			if @talking
				@cur_page += 1
				if @cur_page == @pages.length
					@cur_page -= 1
					if @opts[@state].nil? or @opts[@state].empty?
						@talking = false
						set_animation (@facing_right ? 3 : 0)
						G.player.stop_talking
						@alpha = 0
					else
						@show_opts = true
						G.player.choose
					end
				end
			else
				@talking = true
				@pages = @msgs[@state].split '/'
				@cur_page = 0
				G.player.talk_to self
				@alpha = 0
			end
		end
		if @show_opts
			@opts[@state].each { |o| o.update }
		end
		animate (@facing_right ? @talking_seq_right : @talking_seq), 8 if @talking
		@alpha += 17 if @alpha < 255 and (@can_talk or @talking)
		@alpha -= 17 if @alpha > 0 and not @can_talk and not @talking
		@leaving = false if @alpha == 0
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
		@show_opts = false
		G.player.activate
		G.scene.remove_obst @block if @state == @msgs.length - 1
	end
	
	def draw map
		super map
		if @talking or @leaving
			color = (@alpha << 24) | 0xffffff
			@balloon.draw @x - map.cam.x - 404, @y - map.cam.y - 133, 0, 1, 1, color
			@balloon_arrow.draw @x - map.cam.x - 34, @y - map.cam.y - 35, 0, 1, 1, color
			@writer.write_breaking @pages[@cur_page], @x - map.cam.x - 374, @y - map.cam.y - 123, 380, :justified, 0, @alpha
		elsif @alpha > 0
			color = (@alpha << 24) | 0xffffff
			@ellipsis.draw @x - map.cam.x + @w / 2 - 25, @y - map.cam.y - 45, 0, 1, 1, color
		end
		if @show_opts
			@panel.draw 200, 583 - (@opts[@state].length) * 40, 0
			@opts[@state].each { |b| b.draw }
		elsif @talking and require_item?
			@panel.draw 200, 534, 0
		end
	end
end
