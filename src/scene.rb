# encoding: utf-8

require_relative 'item'
require_relative 'npc'
require_relative 'object'

Entry = Struct.new :x, :y, :dir

class Exit
  def initialize x, y, dir, destiny, dest_entry, switch
    @x = dir == :l ? x - 30 : dir == :r ? x + 30 : x
    @y = y - 150
    @bounds = Rectangle.new @x, @y, 1, 150
    @destiny = destiny
    @dest_entry = dest_entry
    @immediate = (dir != :x)
    if switch
      @active = G.switches.index switch.to_i
      @switch = switch.to_i unless @active
    else
      @active = true
    end
    @arrow = XSprite.new 0, 0, :ui_arrow unless @immediate
    @contact = false
  end

  def update
    if @active
      @arrow.update_alpha if @arrow
      if @bounds.intersects G.player.bounds
        if @immediate
          G.set_scene @destiny, @dest_entry
        else
          unless @contact
            @arrow.fade_in
            @contact = true
            UI.set_hint "Pressione seta para cima para entrar..."
          end
          G.set_scene @destiny, @dest_entry if KB.key_pressed? Gosu::KbUp
        end
      elsif @contact and not @immediate
        @arrow.fade_out
        @contact = false
        UI.set_main_hint
      end
    else
      @active = G.switches.index @switch
    end
  end

  def draw map
    if @arrow and @arrow.alpha > 0
      @arrow.x = @x - map.cam.x - 22; @arrow.y = @y - map.cam.y - 10
      @arrow.draw
    end
  end
end

class Scene
  attr_reader :obsts, :ramps

  def initialize game_type, number, entry
    @game_type =
      case game_type
      when 0 then :math
      when 1 then :port
      when 2 then :logic
      else        :all
      end
    @number = number
    @bg = Res.img "bg_#{@game_type}#{@number}".to_sym
    @map = Map.new 1, 1, @bg.width, @bg.height

    @entries = []
    @exits = []
    @obsts = [
      Block.new(-31, 0, 1, @bg.height, false),
      Block.new(@bg.width + 31, 0, 1, @bg.height, false),
    ]
    @ramps = []
    @items = []
    @npcs = []
    @objects = []
    @effects = []
    File.open("#{Res.prefix}text/#{@game_type}#{@number}.txt").each do |l|
      a = l[2..-1].chomp.split ','
      case l[0]
      when '>'     then @entries << Entry.new(a[0].to_i, a[1].to_i, a[2].to_sym)
      when '<'     then @exits << Exit.new(a[0].to_i, a[1].to_i, a[2].to_sym, a[3].to_i, a[4].to_i, a[5])
      when /\\|\// then @ramps << Ramp.new(a[0].to_i, a[1].to_i, a[2].to_i, a[3].to_i, l[0] == '/')
      when '!'     then check_item a
      when '?'     then @npcs << NPC.new(a[0].to_i, a[1].to_i, a[2], a[3])
      when '*'     then @objects << SceneObject.new(a[0].to_i, a[1].to_i, a[2])
      else              @obsts << Block.new(a[0].to_i, a[1].to_i, a[2].to_i, 1, true)
      end
    end
    @npcs.each do |c|
      @obsts << c.block if c.block
    end

    UI.set_main_hint
    G.player.set_position @entries[entry]
    @map.set_camera G.player.x - 380, G.player.y - 240
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
    @npcs.each { |c| c.update }
    @objects.each { |o| o.update }
    @exits.each { |e| e.update }

    UI.update
  end

  def check_item info
    if info[0][0] == '$'
      sw = info[0][1..-1].to_i
      unless G.switches.index sw
        info1 = G.s_items[sw].split ','
        info2 = G.items[info1[2].to_sym]
        eval "@items << Item.new(info1[0].to_i, info1[1].to_i, :#{info2}, sw)"
      end
    else
      info2 = G.items[info[2].to_sym]
      eval "@items << Item.new(info[0].to_i, info[1].to_i, :#{info2})"
    end
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
    @exits.each do |e|
      e.draw @map
    end
    G.player.draw @map
    @effects.each do |e|
      e.draw
    end
  end
end
