# encoding: utf-8

require 'minigl'
include AGL

class NPC < GameObject
  attr_reader :block

  def initialize x, y, id, final
    f = File.open("#{Res.prefix}text/npc#{id}.txt")
    info = f.readline.chomp.split ','
    h = info[1].to_i
    super x, y - h, info[0].to_i, h, "sprite_npc#{id}", Vector.new(info[2].to_i, info[3].to_i), 3, 2
    @final = final
    @right = @facing_right = (info[4] == 'r')
    @state = 0
    @msgs = []
    @opts = []
    @switches = []

    states = f.read.split "\n\n"
    f.close
    states.each_with_index do |s, i|
      lines = s.split "\n"
      if lines[0][0] == '$'
        sw = lines[0].split[0][1..-1].to_i
        @state = i if G.switches.index sw
      end
      @msgs << (lines[0][0] == '$' ? lines[0][(lines[0].index(' ') + 1)..-1] : lines[0])
      break if i == states.length - 1
      @opts << lines[1..-2].map { |o| o[1..-1] }
      @switches << lines[-1]
    end

    @block = Block.new @x + 5, @y + 5, @w - 10, @h - 5, false if @state < states.length - 1
    @writer = TextHelper.new G.font, 8
    @ellipsis = XSprite.new 0, 0, :ui_ellipsis
    @balloon = XSprite.new 0, 0, :ui_balloon
    @balloon_arrow = XSprite.new 0, 0, "ui_balloonArrow#{@right ? 'R' : ''}"
    @talking_seq = [1, 2, 1, 0, 2, 1, 2, 0]
    @talking_seq_right = [4, 5, 4, 3, 5, 4, 5, 3]
    set_animation 3 if @right
  end

  def update
    @ellipsis.update_alpha; @balloon.update_alpha; @balloon_arrow.update_alpha
    if @talking and not @can_talk
      set_animation (@facing_right ? 3 : 0)
      if @state == @msgs.length - 1; check_finish
      else; G.player.stop_interacting; end
    end
    return if @state == -1
    if bounds.intersects G.player.bounds
      unless @can_talk
        @ellipsis.fade_in
        UI.set_hint "Pressione 'A' para conversar"
        @can_talk = true
      end
    elsif @can_talk
      @ellipsis.fade_out
      UI.set_main_hint
      @can_talk = false
    end
    if @can_talk and G.player.x > @x
      set_animation 3 unless @facing_right
      @facing_right = true
    elsif @can_talk
      set_animation 0 if @facing_right
      @facing_right = false
    end
    if @can_talk and KB.key_pressed? Gosu::KbA
      if @talking
        @cur_page += 1
        if @cur_page == @pages.length
          @cur_page -= 1
          interact
        end
      else
        @talking = true
        @pages = @msgs[@state].split '/'
        @cur_page = 0
        G.player.interact_with self
        UI.set_hint "Pressione 'A' para continuar..."
        @ellipsis.fade_out; @balloon.fade_in; @balloon_arrow.fade_in
      end
    end
    animate (@facing_right ? @talking_seq_right : @talking_seq), 8 if @talking
  end

  def interact
    if @state == @msgs.length - 1
      set_animation (@facing_right ? 3 : 0)
      check_finish
    elsif require_item?
      UI.choose_item
    elsif @opts[@state].size > 0
      UI.choose_opt @opts[@state]
    else
      set_animation (@facing_right ? 3 : 0)
      G.player.stop_interacting
    end
  end

  def require_item?
    return false unless @switches[@state]
    @switches[@state][0] == '!'
  end

  def check_finish
    if @final
      G.player.victory
      G.mission_complete
      UI.mission_complete
      stop_interacting
      @state = -1
    else
      G.player.stop_interacting
    end
  end

  def send what
    s = @switches[@state].split[0]
    if s[0] == '+'
      option = s[1..-1].to_i
      if option == what; next_state
      else; wrong_answer "Resposta errada... :("; end
    elsif s[0] == '!'
      item = s[1..-1].to_sym
      if item == what
        G.player.use_item what, true
        next_state
      else; wrong_answer "Não é esse item... :("; end
    end
  end

  def wrong_answer msg
    s = (0.1 * @switches[@state].split[1].to_i).round
    G.scene.show_message "#{msg}" + (if s > 0 then "   -#{s} ponto#{s > 1 ? 's' : ''}" else '' end), :error
    G.player.score -= s
    G.wrong_answer
  end

  def next_state
    s = @switches[@state].split
    if s.length > 2
      sw = s[2][1..-1].to_i
      G.switches << sw
      if s.length > 3
        if s[3][0] == '$'
          sw = s[3][1..-1].to_i
          G.add_item_switch sw
          G.player.prepare_item G.s_items[sw].split(',')[2].to_sym, sw
        elsif s[3][0] == '!'
          item = s[3][1..-1].to_sym
          G.player.prepare_item item
        end
      end
    end

    @state += 1
    G.correct_answer
    G.player.score += s[1].to_i
    G.scene.show_message "Correto! :)" + (s[1].to_i > 0 ? "   +#{s[1]} pontos" : '')
    if s.length > 4
      G.scene.obsts.delete @block
    end

    @pages = @msgs[@state].split '/'
    @cur_page = 0
    UI.stop_npc_interaction
  end

  def stop_interacting
    @can_talk = @talking = false
    @balloon.fade_out; @balloon_arrow.fade_out
  end

  def draw map
    super map
    return if G.state == :paused

    @ellipsis.x = @x - map.cam.x + @w / 2 - 25; @ellipsis.y = @y - map.cam.y - 45
    @ellipsis.draw 1

    x_off = (@right ? -10 : -404)
    @balloon.x = @x - map.cam.x + x_off; @balloon.y = @y - map.cam.y - 133
    @balloon.draw 1

    x_off = (@right ? @w / 2 : -@w / 34)
    @balloon_arrow.x = @x - map.cam.x + x_off; @balloon_arrow.y = @y - map.cam.y - 35
    @balloon_arrow.draw 1

    x_off = (@right ? 20 : -374)
    @writer.write_breaking @pages[@cur_page],
      @x - map.cam.x + x_off, @y - map.cam.y - 123, 380, :justified, 0, @balloon.alpha, 1 if @pages
  end
end
