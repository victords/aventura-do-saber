require 'minigl'
include AGL

class ItemButton < Button
	def initialize x, y, item_type
		@item_type = item_type
		super(x, y, nil, nil, :ui_itemBtn) {
			G.player.use_item @item_type
		}
	end
end

class Player < GameObject
	attr_reader :name
	attr_writer :talking
	
	def initialize name, char, items = {}
		super 0, 0, (char == :marcus ? 44 : 37), 115, "sprite_#{char}", Vector.new(-8, -5), 3, 2
		@name = name
		@max_speed.x = 10; @max_speed.y = 20
		@anim_indices_left = [0, 1, 0, 2]
		@anim_indices_right = [3, 4, 3, 5]
		
		@items = items
		@item_alpha = 255
		@buttons = {}
		
		@talking = false
		@panel_alpha = 255
		@panel1 = Res.img :ui_panel1
		@panel2 = Res.img :ui_panel2
	end
	
	def update
		################## Movement ##################
		forces = Vector.new 0, 0
		if KB.key_down? Gosu::KbLeft
			set_direction :left if @facing_right
			forces.x -= @bottom ? 0.3 : 0.05
		elsif @speed.x < 0
			forces.x -= 0.1 * @speed.x
		end
		if KB.key_down? Gosu::KbRight
			set_direction :right if not @facing_right
			forces.x += @bottom ? 0.3 : 0.05
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
#				if @facing_right; set_animation 3
#				else; set_animation 8; end
			end
		end
		move forces, G.scene.obsts, G.scene.ramps
		##############################################
		
		if @item_alpha < 255
			@item_alpha += 5
		elsif @item_index
			@item_index = nil
		end
		@buttons.each { |k, v| v.update } unless @talking
		
		@panel_alpha += 17 if @panel_alpha < 255 and not @talking
		@panel_alpha -= 17 if @panel_alpha > 0 and @talking
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
			@buttons[item.type] = ItemButton.new(0, 20, item.type)
			arrange_buttons
		end
		@items[item.type] << item
		@item_alpha = 0
		@item_index = item.type
	end
	
	def use_item item
		@items[item].delete_at(0).use
		if @items[item].length == 0
			@items.delete item
			@buttons.delete item
			arrange_buttons
		end
	end
	
	def arrange_buttons
		i = 0
		@buttons.each do |k, v|
			v.set_position 802 - (@items.length-i) * 57, 20
			i += 1
		end
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
			@buttons.each { |k, v| v.draw @panel_alpha }
			G.font.draw "Itens", base, 5, 0, 1, 1, p_t_color
			i = 0
			@items.each do |k, v|
				if k == @item_index
					color = 0xffffff | (@item_alpha << 24)
					v[0].icon.draw base + i * 57, 23, 0, 1, 1, color
				else
					v[0].icon.draw base + i * 57, 23, 0, 1, 1, p_color
				end
				G.med_font.draw v.length, base + i * 57 + 33, 27, 0, 1, 1, p_t_color if v.length > 1
				i += 1
			end
		end
	end
end
