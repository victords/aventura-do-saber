require 'minigl'
include AGL

class SceneObject < GameObject
	def initialize x, y, id
		f = File.open("data/text/obj#{id}.txt")
		info = f.readline.chomp.split ','
		super x, y, info[0].to_i, info[1].to_i, "sprite_obj#{id}", nil, info[2].to_i, info[3].to_i
		@active = true
		@state = 0
		@opts = []
		@switches = []
		@alpha = 0
		
		states = f.read.split "\n\n"
		f.close
		
		sw = states[-1][1..-1].to_i
		if G.switches.index sw
			@active = false
			return
		end
		states[0..-2].each_with_index do |s, i|
			lines = s.split "\n"
			@opts << []
			if lines.length > 1
				ind = 0
				if lines[0][0] == '$'
					sw = lines[0][1..-1].to_i
					@state = i if G.switches.index sw
					ind += 1
				end
				opts = lines[ind..-2]
				opts.each_with_index do |l, j|
					@opts[i] << Button.new(216, 600 + (j - opts.length) * 40, G.med_font, l, :ui_btn3, 0, 0, false, 5, 5, 0, 0, j+1){ |o| send o }
				end
			end
			@switches << lines[-1]
		end
		
		@exclam = Res.img :ui_exclam
		@panel = Res.img :ui_panel3
	end
	
	def update
		return unless @active
		@can_interact = bounds.intersects G.player.bounds
		if @interacting and not @can_interact
			@leaving = true
			G.player.stop_interacting
		end
		if @can_interact and KB.key_pressed? Gosu::KbA
			if @interacting
				G.player.stop_interacting
			else
				@interacting = true
				G.player.interact_with self
				unless @opts[@state].empty?
					@show_opts = true
					G.player.choose
				end
			end
			@alpha = 0
		end
		if @show_opts
			@opts[@state].each { |o| o.update }
		end
		@alpha += 17 if @alpha < 255 and (@can_interact or @interacting)
		@alpha -= 17 if @alpha > 0 and not @can_interact and not @interacting
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
		if @state == @opts.length
			@active = false
		elsif @opts[@state].empty?
			G.player.activate
			@show_opts = false
		end
	end
	
	def stop_interacting
		@interacting = false
	end
	
	def draw map
		super map
		if @interacting or @leaving
#			color = (@alpha << 24) | 0xffffff
#			@balloon.draw @x - map.cam.x - 404, @y - map.cam.y - 133, 0, 1, 1, color
#			@balloon_arrow.draw @x - map.cam.x - 34, @y - map.cam.y - 35, 0, 1, 1, color
#			@writer.write_breaking @pages[@cur_page], @x - map.cam.x - 374, @y - map.cam.y - 123, 380, :justified, 0, @alpha
		elsif @alpha > 0
			color = (@alpha << 24) | 0xffffff
			@exclam.draw @x + @w / 2 - map.cam.x - 6, @y - map.cam.y - 60, 0, 1, 1, color
		end
		if @show_opts
			@panel.draw 200, 583 - (@opts[@state].length) * 40, 0
			@opts[@state].each { |b| b.draw }
		elsif @interacting and require_item?
			@panel.draw 200, 534, 0
		end
	end
end
