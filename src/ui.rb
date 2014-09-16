require 'minigl'
include AGL

module Fading
	attr_accessor :alpha
	
	def fade_in
		@fading = :in
	end
	
	def fade_out
		@fading = :out
	end
	
	def update_alpha
		if @fading == :in
			if @alpha == 255; @fading = nil
			else; @alpha += 17; end
		elsif @fading == :out
			if @alpha == 0; @fading = nil
			else; @alpha -= 17; end
		end
	end
end

class ItemButton < Button
	include Fading
	
	def initialize item_set
		super(0, 20, nil, nil, :ui_btn4, 0, 0, 0, 0, 0, 0, 0, item_set[0].type){ |i| G.player.use_item i }
		@item_set = item_set
		@alpha = 0
	end
	
	def draw
		super @alpha
		c1 = (@alpha << 24) | 0xffffff; c2 = @alpha << 24
		@item_set[0].icon.draw @x + 3, @y + 3, 0, 1, 1, c1
		G.med_font.draw @item_set.length, @x + 33, @y + 7, 0, 1, 1, c2 if @item_set.length > 1
	end
end

class XButton < Button
	include Fading
	
	def initialize a, b, c, d, e, f, g, h, i, j, k, l, m, &n
		super a, b, c, d, e, f, g, h, i, j, k, l, m, &n
		@alpha = 0
	end
	
	def draw
		super @alpha
	end
end

class XSprite < Sprite
	include Fading
	
	def initialize x, y, img, sprite_cols = nil, sprite_rows = nil
		super x, y, img, sprite_cols, sprite_rows
		@alpha = 255
	end
	
	def draw
		super nil, 1, 1, @alpha
	end
end

class UI
	def self.initialize
		base = -270 + G.med_font.text_width(G.player.name.capitalize)
		base = -210 if base < -210
		@panel1 = XSprite.new base, 0, :ui_panel1
		@panel2 = XSprite.new 0, 0, :ui_panel2
		@panel3 = XSprite.new 0, 0, :ui_panel3
		@panel3.alpha = 0
		@item_buttons = {}
		@opt_buttons = []
	end
	
	def self.update
		@panel1.update_alpha
		@panel2.update_alpha
		@panel3.update_alpha
		@item_buttons.each { |k, v|
			v.update_alpha
			v.update if @choosing_item
		}
		@opt_buttons.each { |b|
			b.update_alpha
			b.update if @choosing_opt
		}
	end
	
	def self.add_item item_set
		if @item_buttons[item_set[0].type].nil?
			@item_buttons[item_set[0].type] = ItemButton.new(item_set)
			arrange_item_buttons
		end
	end
	
	def self.remove_item item
		@item_buttons.delete item
		arrange_item_buttons true
	end
	
	def self.choose_item
		@item_buttons.each do |b|
			b.alpha = 0
			b.fade_in
		end
		arrange_item_buttons true
		@panel3.fade_in
		@choosing_opt = false
	end
	
	def self.choose_opt opts
		@opt_buttons.clear
		opts.each_with_index do |o, i|
			@opt_buttons << XButton.new(216, 600 + (i - opts.length) * 40, G.med_font, o, :ui_btn3, 0, 0, false, 5, 5, 0, 0, i+1){ |p| send p }
		end
		@panel3.fade_in
		@opt_buttons.each { |b| b.fade_in }
		arrange_item_buttons
		@choosing_opt = true
	end
	
	def self.draw
		@panel1.draw
		p_color = (@panel1.alpha << 24) | 0xffffff
		p_t_color = @panel1.alpha << 24
		G.font.draw "Jogador", 5, 5, 0, 1, 1, p_t_color
		G.med_font.draw G.player.name.capitalize, 5, 25, 0, 1, 1, p_t_color
		
		if @item_buttons.length > 0
			@panel2.draw
			@item_buttons.each { |k, v| v.draw }
			G.font.draw "Itens", @items_text_base, 5, 0, 1, 1, p_t_color
		end
		
		@panel3.draw
		@opt_buttons.each { |b| b.draw } if @choosing_opt
	end
	
	private
	
	def self.arrange_item_buttons bottom = false
		@item_buttons.each_with_index do |b, i|
			if bottom; b[1].set_position 225 + i * 70, 555
			else; b[1].set_position 802 - (@item_buttons.length-i) * 57, 20; end
			b[1].alpha = 0
			b[1].fade_in
		end
		@items_text_base = 805 - @item_buttons.length * 57
		@choosing_item = bottom
	end
end