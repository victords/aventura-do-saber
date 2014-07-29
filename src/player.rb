class Player
	attr_reader :name, :char
	
	def initialize name, char, items = []
		@name = name
		@char = Character.new char
		@items = items
		@item_alpha = 255
		
		@panel1 = Res.img :ui_panel1
		@panel2 = Res.img :ui_panel2
	end
	
	def add_item item
		@items << item
		@item_alpha = 0
		@item_index = @items.length - 1
	end
	
	def update
		@char.update G.scene
		if @item_alpha < 255
			@item_alpha += 5
		elsif @item_index
			@item_index = nil
		end
	end
	
	def draw map
		@char.draw map
		
		@panel1.draw 0, 0, 0
		G.font.draw "Jogador", 5, 5, 0, 1, 1, 0xff000000
		G.med_font.draw @name.capitalize, 5, 25, 0, 1, 1, 0xff000000
		
		if @items.length > 0
			@panel2.draw 740, @items.length * 42 - 260, 0
			G.font.draw "Itens", 758, 5, 0, 1, 1, 0xff000000
			@items.each_with_index do |item, i|
				if i == @item_index
					color = 0xffffff | (@item_alpha << 24)
					item.icon.draw 758, 25 + i * 42, 0, 1, 1, color
				else
					item.icon.draw 758, 25 + i * 42, 0
				end
			end
		end
	end
end
