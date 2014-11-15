require 'minigl'
require_relative 'ui'
include AGL

class Player < GameObject
  attr_reader :name, :score

  def initialize name, char
    super 0, 0, (char == :marcus ? 44 : 37), 115, "sprite_#{char}", Vector.new(-8, -5), 6, 2
    @name = name
    @max_speed.x = 5.5; @max_speed.y = 20
    @anim_indices_left = [0, 1, 0, 2]
    @anim_indices_victory_left = [3, 4, 5]
    @anim_indices_right = [6, 7, 6, 8]
    @anim_indices_victory_right = [9, 10, 11]
    @items = {}
    @score = 0
  end

  def reset
    @victory = nil
  end

  def update
    return if @victory == 2

    if @victory
      animate @anim_indices, 8
      @victory = 2 if @img_index == @anim_indices[-1]
      return
    end

    if @prepared_item
      add_item @prepared_item, (@obj.nil? or (@obj.is_a? SceneObject and @obj.require_item?)), @obj
      @prepared_item = nil
    end

    forces = Vector.new 0, 0
    if KB.key_down? Gosu::KbLeft
      set_direction :left if @facing_right
      forces.x -= @bottom ? 0.25 : 0.03
    elsif @speed.x < 0
      forces.x -= 0.1 * @speed.x
    end
    if KB.key_down? Gosu::KbRight
      set_direction :right unless @facing_right
      forces.x += @bottom ? 0.25 : 0.03
    elsif @speed.x > 0
      forces.x -= 0.1 * @speed.x
    end
    if @bottom
      if @speed.x != 0
        animate @anim_indices, 30 / @speed.x.abs
      elsif @facing_right
        set_animation 6
      else
        set_animation 0
      end
      if KB.key_pressed? Gosu::KbSpace
        forces.y -= 13.7 + 0.4 * @speed.x.abs
      end
    end
    move forces, G.scene.obsts, G.scene.ramps
  end

  def set_position entry
    @x = entry.x
    @y = entry.y - @h
    @speed.x = @speed.y = 0

    @facing_right = (entry.dir != :l)
    @anim_indices = (entry.dir == :l ? @anim_indices_left : @anim_indices_right)
    set_animation @anim_indices[0]
  end

  def add_item item, show = true, bottom = false
    @items[item.type] = [] if @items[item.type].nil?
    @items[item.type] << item
    UI.add_item @items[item.type], show, bottom
  end

  def prepare_item item, switch = nil
    info = G.items[item]
    eval "@prepared_item = Item.new 0, 0, :#{info}" + (switch ? ", #{switch}" : '')
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

  def score= value
    @score = value
    @score = 0 if @score < 0
  end

  def victory
    @victory = 1
    if @facing_right
      @anim_indices = @anim_indices_victory_right
    else
      @anim_indices = @anim_indices_victory_left
    end
    set_animation @anim_indices[0]
  end

  def ui_add_items
    @items.each { |k, v| UI.add_item(v, true) }
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
