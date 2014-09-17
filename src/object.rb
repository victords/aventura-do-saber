require 'minigl'
include AGL

class SceneObject < GameObject
	def initialize x, y, id
		f = File.open("data/text/obj#{id}.txt")
		info = f.readline.chomp.split ','
		super x, y, info[0].to_i, info[1].to_i, "sprite_obj#{id}", nil, info[2].to_i, info[3].to_i
		@exclam = XSprite.new 0, 0, :ui_exclam
		@active = true
		@state = 0
		@opts = []
		@switches = []
		
		states = f.read.split "\n\n"
		f.close
		sw = states[-1][1..-1].to_i
		if G.switches.index sw
			@active = false
			return
		end
		states[0..-2].each_with_index do |s, i|
			lines = s.split "\n"
			if lines.length > 1
				ind = 0
				if lines[0][0] == '$'
					sw = lines[0][1..-1].to_i
					@state = i if G.switches.index sw
					ind += 1
				end
				@opts << lines[ind..-2]
			else
				@opts << []
			end
			@switches << lines[-1]
		end
	end
	
	def update
		@exclam.update_alpha
		return unless @active
		if bounds.intersects G.player.bounds
			@exclam.fade_in unless @can_interact
			@can_interact = true
		else
			@exclam.fade_out if @can_interact
			@can_interact = false
		end
		if @interacting and not @can_interact
			G.player.stop_interacting
		end
		if @can_interact and KB.key_pressed? Gosu::KbA
			if @interacting
				G.player.stop_interacting
			else
				@interacting = true
				@exclam.fade_out
				G.player.interact_with self
				interact
			end
		end
	end
	
	def interact
		if require_item?
			UI.choose_item
		else
			UI.choose_opt @opts[@state]
		end
	end
	
	def require_item?
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
				G.player.use_item what, true
				next_state
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
			@exclam.fade_out
			G.player.stop_interacting
		else
			interact
		end
	end
	
	def stop_interacting
		@can_interact = @interacting = false
	end
	
	def draw map
		super map
		if @active
			@exclam.x = @x + @w / 2 - map.cam.x - 6; @exclam.y = @y - map.cam.y - 60
			@exclam.draw
		end
	end
end
