require 'minigl'
include AGL

class SceneObject < GameObject
	def initialize x, y, id
		f = File.open("data/text/obj#{id}.txt")
		info = f.readline.chomp.split ','
		super x, y, info[0].to_i, info[1].to_i, "sprite_obj#{id}", nil, info[2].to_i, info[3].to_i
		@state = 0
		@switches = []
		states = f.read.split "\n"
		states.each_with_index do |s, i|
			s = s.split(',')
			unless s[0].empty?
				sw = s[0][1..-1].to_i
				@state = i if G.switches.index sw
			end
			@switches << s[1]
		end
		
		@exclam = Res.img :ui_exclam
		@panel = Res.img :ui_panel3
		@alpha = 0
	end
	
	def update
		@can_interact = bounds.intersects G.player.bounds
		@alpha += 17 if @alpha < 255 and @can_interact
		@alpha -= 17 if @alpha > 0 and not @can_interact
	end
	
	def require_item?
		return false unless @switches[@state]
		@switches[@state][0] == '!'
	end
	
	def send what
		
	end
	
	def next_state
		s = @switches[@state].split
		if s.length > 1
			sw = s[1][1..-1].to_i
			G.switches << sw
		end
		@state += 1
	end
	
	def draw map
		super map
		if @can_interact or @alpha > 0
			color = (@alpha << 24) | 0xffffff
			@exclam.draw @x + @w / 2 - 6, @y - 60, 0, 1, 1, color
		end
	end
end
