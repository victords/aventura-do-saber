require 'minigl'
include AGL

class ItemButton < Button
	def initialize item_set
		super(0, 20, nil, nil, :ui_btn4, 0, 0, 0, 0, 0, 0, 0, item_set[0].type){ |i| G.player.use_item i }
		@item_set = item_set
	end
	
	def draw alpha
		super alpha
		c1 = (alpha << 24) | 0xffffff; c2 = alpha << 24
		@item_set[0].icon.draw @x + 3, @y + 3, 0, 1, 1, c1
		G.med_font.draw @item_set.length, @x + 33, @y + 7, 0, 1, 1, c2 if @item_set.length > 1
	end
end

class Player < GameObject
	attr_reader :name
	
	def initialize name, char, items = {}
		super 0, 0, (char == :marcus ? 44 : 37), 115, "sprite_#{char}", Vector.new(-8, -5), 3, 2
		@name = name
		@max_speed.x = 5.5; @max_speed.y = 20
		@anim_indices_left = [0, 1, 0, 2]
		@anim_indices_right = [3, 4, 3, 5]
		@active = true
		
		@items = items
		@buttons = {}
		@button_alpha = 255
		
		@panel_alpha = 255
		@panel1 = Res.img :ui_panel1
		@panel2 = Res.img :ui_panel2
	end
	
	def update
		################## Movement ##################
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
		##############################################
		
		if @npc
			@buttons.each { |k, v| v.update } if @npc.require_item?
			if @panel_alpha > 0
				@panel_alpha -= 17
				@button_alpha -= 17
				arrange_buttons true if @panel_alpha == 0 and @npc.require_item?
			elsif @npc.require_item? and @button_alpha < 255
				@button_alpha += 17
			elsif not @npc.require_item? and @button_alpha > 0
				@button_alpha -= 17
			end
		else
			@buttons.each { |k, v| v.update }
			@panel_alpha += 17 if @panel_alpha < 255
			if @button_alpha < 255
				@button_alpha += 17
			elsif @item_index
				@item_index = nil
			end
		end
	end
	
	def set_position entry
		@x = entry.x
		@y = entry.y
		@speed.x = @speed.y = 0
		
		@facing_right = (entry.dir != :l)
		@anim_indices = (entry.dir == :l ? @anim_indices_left : @anim_indices_right)
		set_animation @anim_indices[0]
	end
	
	def add_item item
		if @items[item.type].nil?
			@items[item.type] = []
			@items[item.type] << item
			@buttons[item.type] = ItemButton.new(@items[item.type])
			arrange_buttons
		else
			@items[item.type] << item
		end
		@button_alpha = 0
		@item_index = item.type
	end
	
	def use_item item, from_npc = false
		if @npc and not from_npc
			@npc.send item
		else
			@items[item].delete_at(0).use
			if @items[item].length == 0
				@items.delete item
				@buttons.delete item
				arrange_buttons if @npc.nil?
			end
		end
	end
	
	def talk_to npc
		@npc = npc
	end
	
	def choose
		arrange_buttons true
		@active = false
	end
	
	def stop_talking
		arrange_buttons
		@npc = nil
		activate
	end
	
	def activate
		@active = true
	end
	
	def draw map
		super map
		
		p_color = (@panel_alpha << 24) | 0xffffff
		p_t_color = (@panel_alpha << 24) | 0
		base = -270 + G.med_font.text_width(@name.capitalize)
		base = -210 if base < -210
		@panel1.draw base, 0, 0, 1, 1, p_color
		G.font.draw "Jogador", 5, 5, 0, 1, 1, p_t_color
		G.med_font.draw @name.capitalize, 5, 25, 0, 1, 1, p_t_color
		
		if @items.length > 0
			base = 805 - @items.length * 57
			@panel2.draw base - 20, 0, 0, 1, 1, p_color
			@buttons.each { |k, v| v.draw @button_alpha }
			G.font.draw "Itens", base, 5, 0, 1, 1, p_t_color
		end
	end
	
	private
	
	def arrange_buttons bottom = false
		@buttons.each_with_index do |b, i|
			if bottom; b[1].set_position 225 + i * 70, 555
			else; b[1].set_position 802 - (@items.length-i) * 57, 20; end
		end
	end
	
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
