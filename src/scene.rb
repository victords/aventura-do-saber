require './item'

Entry = Struct.new :x, :y, :dir

class Scene
	attr_reader :character, :obsts, :ramps
	
	def initialize number, character, entry
		@number = number
		@character = character
		@entry = entry
		@bg = Res.img "scene#{number}".to_sym
		
		reset
	end
	
	def update
		@character.update self
		
		@items.each do |i|
			i.update self
			@items.delete i if i.dead
		end
	end
	
	def reset
		@entries = []
		@obsts = []
		@ramps = []
		@items = []
		File.open("data/scene/#{@number}.txt") do |f|
			f.each_line do |l|
				a = l[2..-1].chomp.split ','
				if l[0] == '>'
					@entries << Entry.new(a[0].to_i, a[1].to_i, a[2].to_sym)
				elsif l[0] == '/' or l[0] == '\\'
					@ramps << Ramp.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, l[0] == '/')
				elsif l[0] == '!'
					@items << Item.new(a[0].to_i, a[1].to_i, a[2].to_sym)
				else
					@obsts << Block.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, true)
				end
			end
		end
		
		@character.set_position @entries[@entry]
	end
	
	def draw
		@bg.draw 0, 0, 0
		@character.draw
		@items.each do |i|
			i.draw
		end
	end
end
