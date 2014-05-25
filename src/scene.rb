require_relative 'item'
require_relative 'npc'

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
		
		@npcs.each do |c|
			c.update self
		end
	end
	
	def reset
		@entries = []
		@obsts = []
		@ramps = []
		@items = []
		@npcs = []
		File.open("data/scene/#{@number}.txt") do |f|
			f.each_line do |l|
				a = l[2..-1].chomp.split ','
				if l[0] == '>'
					@entries << Entry.new(a[0].to_i, a[1].to_i, a[2].to_sym)
				elsif l[0] == '/' or l[0] == '\\'
					@ramps << Ramp.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, l[0] == '/')
				elsif l[0] == '!'
					@items << Item.new(a[0].to_i, a[1].to_i, a[2].to_sym)
				elsif l[0] == '?'
					@npcs << NPC.new(a[0].to_i, a[1].to_i, a[2].to_i)
				else
					@obsts << Block.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, true)
				end
			end
		end
		@npcs.each do |c|
			@obsts << c
		end
		
		@character.set_position @entries[@entry]
	end
	
	def draw
		@bg.draw 0, 0, 0
		@character.draw
		@items.each do |i|
			i.draw
		end
		@npcs.each do |c|
			c.draw
		end
	end
end