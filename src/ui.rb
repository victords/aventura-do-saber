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
    @tooltip = XText.new item_set[0].name, 0, 0, 0xffffff, G.font
  end

  def update
    super
    @tooltip.update_alpha
    if Mouse.over? @x, @y, @w, @h
      @tooltip.fade_in
    else
      @tooltip.fade_out
    end
  end

  def set_position x, y
    super
    @tooltip.x = x + 19 - G.font.text_width(@tooltip.text) / 2
    @tooltip.y = y - 18
  end

  def draw
    super @alpha
    c1 = (@alpha << 24) | 0xffffff; c2 = @alpha << 24
    @item_set[0].icon.draw @x + 3, @y + 3, 0, 1, 1, c1
    G.med_font.draw @item_set.length, @x + 33, @y + 7, 0, 1, 1, c2 if @item_set.length > 1
    @tooltip.draw
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
    @alpha = 0
  end

  def draw z_index = 0
    super nil, 1, 1, @alpha, 0xffffff, nil, z_index
  end
end

class XText
  include Fading

  attr_accessor :text, :x, :y

  def initialize text, x, y, color = 0xffffff, font = G.med_font, line_break = false
    @text = text
    @x = x
    @y = y
    @color = color
    @alpha = 0
    @font = font
    @writer = line_break ? TextHelper.new(font) : nil
  end

  def draw
    if @writer
      @writer.write_breaking @text, @x, @y, 800, :left, 0, @alpha
    else
      aa = @alpha << 24
      @font.draw @text, @x - 1, @y - 1, 0, 1, 1, aa
      @font.draw @text, @x, @y - 1, 0, 1, 1, aa
      @font.draw @text, @x + 1, @y - 1, 0, 1, 1, aa
      @font.draw @text, @x + 1, @y, 0, 1, 1, aa
      @font.draw @text, @x + 1, @y + 1, 0, 1, 1, aa
      @font.draw @text, @x, @y + 1, 0, 1, 1, aa
      @font.draw @text, @x - 1, @y + 1, 0, 1, 1, aa
      @font.draw @text, @x - 1, @y, 0, 1, 1, aa
      @font.draw @text, @x, @y, 0, 1, 1, aa | @color
    end
  end
end

class TextEffect < XText
  attr_reader :dead

  def initialize text, level
    x = 400 - G.med_font.text_width(text) / 2
    y = 300 - G.med_font.height / 2
    color =
      case level
      when :info then 0xffffff
      when :warn then 0xddcc00
      when :error then 0xff0000
      end
    super text, x, y, color
    @steps = 0
    fade_in
  end

  def update
    @y -= 0.3
    if @steps == 300; fade_out
    else; @steps += 1; end
    update_alpha
    @dead = true if @alpha == 0
  end
end

class UI
  def self.initialize
    @panel1 = XSprite.new 0, 0, :ui_panel1
    @panel2 = XSprite.new 0, 0, :ui_panel2
    @panel3 = XSprite.new 200, 0, :ui_panel3
    @main_hints = [
      "Use as setas esquerda e direita para se mover",
      "Use a barra de espaço para pular",
      "Pressione 'Esc' para pausar o jogo"
    ]
    @hint = XText.new @main_hints[0], 10, 565, 0x00ffff
    @hint_index = 0
    @hint_timer = 0
    @showing_main_hint = false
    @panel1.alpha = @hint.alpha = 255
    @item_buttons = {}
    @opt_buttons = []
    @mission_complete = nil
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
    if G.hints
      @hint.update_alpha
      if @changing_hint and @hint.alpha == 0
        @hint.text = @changing_hint
        if @hint_pos
          @hint.x = @hint_pos.x; @hint.y = @hint_pos.y
          @hint_pos = nil
        else
          @hint.x = 10; @hint.y = 565
        end
        @changing_hint = nil
        @hint.fade_in
      end
      if @showing_main_hint
        @hint_timer += 1
        set_main_hint if @hint_timer == 180
      end
    end
    @mission_complete.update_alpha if @mission_complete
  end

  def self.add_item item_set, show, bottom = false
    if @item_buttons[item_set[0].type].nil?
      @item_buttons[item_set[0].type] = ItemButton.new(item_set)
      arrange_item_buttons bottom if show
    end
  end

  def self.remove_item item
    @item_buttons.delete item
    arrange_item_buttons true
  end

  def self.choose_item
    @item_buttons.each { |k, v| v.alpha = 0; v.fade_in }
    arrange_item_buttons true
    @panel3.y = 538
    @panel3.fade_in
    @choosing_opt = false
    @choosing_item = true
    set_hint "Clique num item para usá-lo", 200, @panel3.y - 35
  end

  def self.choose_opt opts
    @opt_buttons.clear
    opts.each_with_index do |o, i|
      @opt_buttons << XButton.new(216, 600 + (i - opts.length) * 40, G.med_font, o,
                                  :ui_btn3, 0, 0, false, 5, 5, 0, 0, i+1){ |p| G.player.send_to_obj p }
    end
    @panel3.y = 584 - opts.length * 40
    @panel3.fade_in
    @opt_buttons.each { |b| b.fade_in }
    if @choosing_item
      @item_buttons.each { |k, v| v.fade_out }
      @choosing_item = false
    end
    @choosing_opt = true
    set_hint "Clique na opção desejada", 200, @panel3.y - 35
  end

  def self.start_player_interaction
    @panel1.fade_out
    @panel2.fade_out
    @item_buttons.each { |k, v| v.fade_out }
  end

  def self.stop_player_interaction
    arrange_item_buttons
    @panel1.fade_in
    @panel2.fade_in
    @panel3.fade_out
    @opt_buttons.each { |b| b.fade_out }
    @choosing_item = @choosing_opt = false
    set_main_hint
  end

  def self.stop_npc_interaction
    @panel3.fade_out
    @opt_buttons.each { |b| b.fade_out }
    @item_buttons.each { |k, v| v.fade_out }
    @choosing_opt = false
    @choosing_item = false
    set_hint "Pressione 'A' para continuar..."
  end

  def self.set_hint text, x = nil, y = nil
    @changing_hint = text
    @hint_pos = Vector.new x, y if x
    @hint.fade_out
    @showing_main_hint = false
  end

  def self.set_main_hint
    set_hint @main_hints[@hint_index]
    @hint_index += 1
    @hint_index = 0 if @hint_index == @main_hints.length
    @hint_timer = 0
    @showing_main_hint = true
  end

  def self.mission_complete
    text = "MISSÃO COMPLETA!"
    @mission_complete = XText.new text, 400 - G.big_font.text_width(text) / 2, 10, 0xffffff, G.big_font
    @mission_complete.fade_in
    @panel1.fade_out
    @panel2.fade_out
    @panel3.fade_out
    @item_buttons.each { |k, v| v.fade_out }
    @opt_buttons.each { |b| b.fade_out }
    set_hint "Pressione 'A' ou clique para continuar..."
  end

  def self.draw
    @panel1.draw
    p_color = (@panel1.alpha << 24) | 0xffffff
    p_t_color = @panel1.alpha << 24
    G.font.draw "Jogador", 5, 2, 0, 1, 1, p_t_color
    G.med_font.draw G.player.name.split.map{|s|s.capitalize}.join(' '), 5, 25, 0, 1, 1, p_t_color
    s = G.player.score
    G.font.draw_rel "#{s} ponto#{s > 1 ? 's' : ''}", 285, 2, 0, 1, 0, 1, 1, p_t_color

    @panel3.draw
    @opt_buttons.each { |b| b.draw } if @choosing_opt

    if @item_buttons.length > 0
      @panel2.draw
      @item_buttons.each { |k, v| v.draw }
      G.font.draw "Itens", @items_text_base, 2, 0, 1, 1, p_t_color
    end

    @mission_complete.draw if @mission_complete

    if G.hints
      @hint.draw
    end
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
    @panel2.x = @items_text_base - 20
    @panel2.fade_in if @item_buttons.length == 1 and not bottom
  end
end
