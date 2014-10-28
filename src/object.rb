require 'minigl'
include AGL

class SceneObject < GameObject
  def initialize x, y, id
    f = File.open("#{Res.prefix}text/obj#{id}.txt")
    info = f.readline.chomp.split ','
    super x, y, info[0].to_i, info[1].to_i, "sprite_obj#{id}", nil, info[2].to_i, info[3].to_i
    @exclam = XSprite.new 0, 0, :ui_exclam
    @text = XText.new "", 10, 10
    @active = true
    @state = 0
    @opts = []
    @switches = []
    @msgs = []
    @anims = []

    states = f.read.split "\n\n"
    f.close
    sw = states[-1][1..-1].to_i
    if G.switches.index sw
      @active = false
      l = states[-2].split("\n")[-1].split('/')
      set_animation l[2].split(',')[-1].to_i
      return
    end
    states[0..-2].each_with_index do |s, i|
      lines = s.split "\n"
      if lines.length > 1
        ind = 0
        if lines[0][0] == '$'
          sw = lines[0][1..-1].to_i
          if G.switches.index sw
            @state = i
            set_animation @anims[i - 1][0]
          end
          ind += 1
        end
        @opts << lines[ind..-2].map { |o| o[1..-1] }
      else
        @opts << []
      end
      l = lines[-1].split '/'
      @switches << l[0]
      @msgs << l[1]
      eval "@anims << #{l[2]}"
    end
  end

  def update
    @exclam.update_alpha
    @text.update_alpha

    if @animating
      if @anim_step < 7 * (@anims[@state-1].length - 1)
        animate @anims[@state-1], 7
        @anim_step += 1
      else
        @animating = false
      end
    end

    return unless @active
    if bounds.intersects G.player.bounds
      unless @can_interact
        @exclam.fade_in
        UI.set_hint "Pressione 'A' para interagir..."
        @can_interact = true
      end
    elsif @can_interact
      @exclam.fade_out
      UI.set_main_hint
      @can_interact = false
    end
    if @interacting and not @can_interact
      G.player.stop_interacting
      UI.set_main_hint
    end
    if @can_interact and KB.key_pressed? Gosu::KbA
      if @interacting
        G.player.stop_interacting
      else
        @interacting = true
        @exclam.fade_out
        @text.fade_in
        G.player.interact_with self
        interact
      end
    end
  end

  def interact
    if require_item?
      @text.text = "Usar qual item?"
      UI.choose_item
    else
      @text.text = "O que fazer?"
      UI.choose_opt @opts[@state]
    end
  end

  def require_item?
    @switches[@state][0] == '!'
  end

  def send what
    s = @switches[@state].split[0]
    if s[0] == '+'
      option = s[1..-1].to_i
      if option == what; next_state
      else; wrong_answer; end
    elsif s[0] == '!'
      item = s[1..-1].to_sym
      if item == what
        G.player.use_item what, true
        next_state
      else; wrong_answer; end
    end
  end

  def wrong_answer
    G.scene.show_message "Nenhum efeito... =/", :warn
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
          G.player.prepare_item G.s_items[sw].split(',')[2].to_sym
        else
          item = s[3][1..-1].to_sym
          G.player.prepare_item item
        end
      end
    end
    if @anims[@state]
      set_animation @anims[@state][0]
      @animating = true
      @anim_step = 0
    end
    G.correct_answer
    G.player.score += s[1].to_i
    G.scene.show_message "#{@msgs[@state]}   + #{s[1]} pontos"
    @state += 1
    if @state == @opts.length
      @active = false
      @exclam.fade_out
      G.player.stop_interacting
    else
      interact
    end
  end

  def stop_interacting
    @text.fade_out
    @can_interact = @interacting = false
  end

  def draw map
    super map
    if @active
      @exclam.x = @x + @w / 2 - map.cam.x - 6; @exclam.y = @y - map.cam.y - 60
      @exclam.draw
      @text.draw
    end
  end
end
