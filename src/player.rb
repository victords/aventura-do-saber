require 'minigl'

class ItemButton < AGL::Button
	def initialize x, y, item_type
		@item_type = item_type
		super(x, y, nil, nil, :ui_itemBtn) {
			G.player.use_item @item_type
		}
	end
end

class Player
	attr_reader :name, :char
	
	def initialize name, char, items = {}
		@name = name
		@char = Character.new char
		@items = items
		@item_alpha = 255
		
		@panel1 = Res.img :ui_panel1
		@panel2 = Res.img :ui_panel2
		
		@buttons = {}
	end
	
	def add_item item
		if @items[item.type].nil?
			@items[item.type] = []
			@buttons[item.type] = ItemButton.new(0, 20, item.type)
			i = 0
			@buttons.each do |k, v|
				v.set_position 802 - (@items.length-i) * 57, 20
				i += 1
			end
		end
		@items[item.type] << item
		@item_alpha = 0
		@item_index = item.type
	end
	
	def use_item item
		@items[item][0].use
	end
	
	def update
		@char.update G.scene
		if @item_alpha < 255
			@item_alpha += 5
		elsif @item_index
			@item_index = nil
		end
		@buttons.each { |k, v| v.update }
	end
	
	def draw map
		@char.draw map
		
		@panel1.draw 0, 0, 0
		G.font.draw "Jogador", 5, 5, 0, 1, 1, 0xff000000
		G.med_font.draw @name.capitalize, 5, 25, 0, 1, 1, 0xff000000
		
		if @items.length > 0
			base = 805 - @items.length * 57
			@panel2.draw base - 20, 0, 0
			@buttons.each { |k, v| v.draw }
			G.font.draw "Itens", base, 5, 0, 1, 1, 0xff000000
			i = 0
			@items.each do |k, v|
				if k == @item_index
					color = 0xffffff | (@item_alpha << 24)
					v[0].icon.draw base + i * 57, 23, 0, 1, 1, color
				else
					v[0].icon.draw base + i * 57, 23, 0
				end
				G.med_font.draw v.length, base + i * 57 + 33, 27, 0, 1, 1, 0xff000000 if v.length > 1
				i += 1
			end
		end
	end
end
