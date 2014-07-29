require_relative 'item'
require_relative 'npc'

Entry = Struct.new :x, :y, :dir

class Scene
	attr_reader :obsts, :ramps
	
	def initialize number, entry
		@number = number
		@entry = entry
		@bg = Res.img "bg_scene#{number}".to_sym
		@map = Map.new 1, 1, @bg.width, @bg.height
		
		reset
	end
	
	def update
		G.player.update
		@map.set_camera G.player.char.x - 380, G.player.char.y - 240
		
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
		File.open("data/scene/#{@number}.txt").each do |l|
			a = l[2..-1].chomp.split ','
			case l[0]
			when '>'     then @entries << Entry.new(a[0].to_i, a[1].to_i, a[2].to_sym)
			when /\\|\// then @ramps << Ramp.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, l[0] == '/')
			when '!'     then @items << Item.new(a[0].to_i, a[1].to_i, a[2].to_sym)
			when '?'     then @npcs << NPC.new(a[0].to_i, a[1].to_i, a[2].to_i)
			else              @obsts << Block.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, true)
			end
		end
		@npcs.each do |c|
			@obsts << c
		end
		
		G.player.char.set_position @entries[@entry]
	end
	
	def draw
		@bg.draw -@map.cam.x, -@map.cam.y, 0
		@items.each do |i|
			i.draw @map
		end
		@npcs.each do |c|
			c.draw @map
		end
		G.player.draw @map
	end
end
