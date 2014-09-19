require_relative 'item'
require_relative 'npc'
require_relative 'object'

Entry = Struct.new :x, :y, :dir

class Scene
	attr_reader :obsts, :ramps
	
	def initialize game_type, number, entry
		@game_type = game_type
		@number = (number ? number : 1)
		@entry = entry
		@bg = Res.img "bg_#{@game_type}#{@number}".to_sym
		@map = Map.new 1, 1, @bg.width, @bg.height
		
		reset
	end
	
	def update
		G.player.update
		@map.set_camera G.player.x - 380, G.player.y - 240
		
		@items.each do |i|
			i.update
			@items.delete i if i.dead
		end
		@effects.each do |e|
			e.update
			@effects.delete e if e.dead
		end
		@npcs.each do |c|
			c.update
		end
		@objects.each do |o|
			o.update
		end
		
		UI.update
	end
	
	def reset
		@entries = []
		@obsts = []
		@ramps = []
		@items = []
		@npcs = []
		@objects = []
		@effects = []
		File.open("data/text/#{@game_type}#{@number}.txt").each do |l|
			a = l[2..-1].chomp.split ','
			case l[0]
			when '>'     then @entries << Entry.new(a[0].to_i, a[1].to_i, a[2].to_sym)
			when /\\|\// then @ramps << Ramp.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, l[0] == '/')
			when '!'     then check_item a
			when '?'     then @npcs << NPC.new(a[0].to_i, a[1].to_i, a[2])
			when '*'     then @objects << SceneObject.new(a[0].to_i, a[1].to_i, a[2])
			else              @obsts << Block.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, true)
			end
		end
		@npcs.each do |c|
			@obsts << c.block if c.block
		end
		
		G.player.set_position @entries[@entry]
	end
	
	def check_item info
		if info[0][0] == '$'
			sw = info[0][1..-1].to_i
			unless G.switches.index sw
				info = G.items[sw].split ','
				@items << Item.new(info[0].to_i, info[1].to_i, info[2].to_sym)
			end
		else
			@items << Item.new(info[0].to_i, info[1].to_i, info[2].to_sym)
		end
	end
	
	def remove_obst obst
		@obsts.delete obst
	end
	
	def add_effect id, x, y
		eval "@effects << Effect.new(#{x}, #{y}, :fx_#{id}, #{G.effects[id].chomp})"
	end
	
	def show_message msg, level = :info
		@effects << TextEffect.new(msg, level)
	end
	
	def draw
		@bg.draw -@map.cam.x, -@map.cam.y, 0
		@items.each do |i|
			i.draw @map
		end
		@npcs.each do |c|
			c.draw @map
		end
		@objects.each do |o|
			o.draw @map
		end
		G.player.draw @map
		@effects.each do |e|
			e.draw
		end
		
		UI.draw
	end
end
