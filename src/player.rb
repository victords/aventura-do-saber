require 'minigl'
require_relative 'ui'
include AGL

class Player < GameObject
	attr_reader :name
	
	def initialize name, char
		super 0, 0, (char == :marcus ? 44 : 37), 115, "sprite_#{char}", Vector.new(-8, -5), 3, 2
		@name = name
		@max_speed.x = 5.5; @max_speed.y = 20
		@anim_indices_left = [0, 1, 0, 2]
		@anim_indices_right = [3, 4, 3, 5]
		@active = true
		@items = {}
	end
	
	def update
		if @prepared_item
			add_item @prepared_item, (@obj.nil? or @obj.require_item?), @obj
			@prepared_item = nil
		end
		
		forces = Vector.new 0, 0
		if @active
			if KB.key_down? Gosu::KbLeft
				set_direction :left if @facing_right
				forces.x -= @bottom ? 0.25 : 0.03
			elsif @speed.x < 0
				forces.x -= 0.1 * @speed.x
			end
			if KB.key_down? Gosu::KbRight
				set_direction :right if not @facing_right
				forces.x += @bottom ? 0.25 : 0.03
			elsif @speed.x > 0
				forces.x -= 0.1 * @speed.x
			end
			if @bottom
				if @speed.x != 0
					animate @anim_indices, 30 / @speed.x.abs
				elsif @facing_right
					set_animation 3
				else
					set_animation 0
				end
				if KB.key_pressed? Gosu::KbUp
					forces.y -= 13.7 + 0.4 * @speed.x.abs
#					if @facing_right; set_animation 3
#					else; set_animation 8; end
				end
			end
		end
		move forces, G.scene.obsts, G.scene.ramps
	end
	
	def set_position entry
		@x = entry.x
		@y = entry.y
		@speed.x = @speed.y = 0
		
		@facing_right = (entry.dir != :l)
		@anim_indices = (entry.dir == :l ? @anim_indices_left : @anim_indices_right)
		set_animation @anim_indices[0]
	end
	
	def add_item item, show = true, bottom = false
		if @items[item.type].nil?
			@items[item.type] = []
			@items[item.type] << item
		else
			@items[item.type] << item
		end
		UI.add_item @items[item.type], show, bottom
	end
	
	def prepare_item item
		info = G.items[item]
		eval "@prepared_item = Item.new 0, 0, :#{info}"
	end
	
	def use_item item, from_obj = false
		if from_obj
			@items[item].delete_at(0).use
			if @items[item].length == 0
				@items.delete item
				UI.remove_item item
			end
		else
			@obj.send item
		end
	end
	
	def interact_with obj
		@obj = obj
		UI.start_player_interaction
	end
	
	def send_to_obj what
		@obj.send what
	end
	
	def stop_interacting
		@obj.stop_interacting
		@obj = nil
		UI.stop_player_interaction
	end
	
	private
	
	def set_direction dir
		if dir == :left
			@facing_right = false
			@anim_indices = @anim_indices_left
		else
			@facing_right = true
			@anim_indices = @anim_indices_right
		end
		set_animation @anim_indices[0]
	end
end
