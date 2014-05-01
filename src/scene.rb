require_relative 'lib/game_object'

class Scene
	attr_reader :obsts, :ramps
	
	def initialize number, character, entry
		@number = number
		@character = character
		@entry = entry
		@bg = Res.img "scene#{number}".to_sym
		
		@entries = []
		@obsts = []
		@ramps = []
		File.open("data/scene/#{number}.txt") do |f|
			f.each_line do |l|
				if l[0] == '>'
					a = l[2..-1].split ','
					@entries << {pos: Vector.new(a[0].to_i, a[1].to_i), dir: a[2].chomp.to_sym}
				elsif l[0] == '#' or l[0] == '$'
					a = l[2..-1].split ','
					@ramps << Ramp.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, l[0] == '#')
				else
					a = l.split ','
					@obsts << Block.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, true)
				end
			end
		end
		
		@character.set_position @entries[@entry]
	end
	
	def update
		@character.update self
	end
	
	def reset
		@character.set_position @entries[@entry]
	end
	
	def draw
		@bg.draw 0, 0, 0
		@character.draw
	end
end
