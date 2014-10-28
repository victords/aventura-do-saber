require 'minigl'
include AGL

class Item < GameObject
  attr_reader :type, :dead, :icon

  def initialize x, y, type, w, h, img_gap_x, img_gap_y, score, switch = nil
    super x, y, w, h, "sprite_#{type}", Vector.new(img_gap_x, img_gap_y)
    @type = type
    @score = score
    @switch = switch
    @icon = Res.img "icon_#{type}"
  end

  def update
    forces = Vector.new(0, 0)
    move forces, G.scene.obsts, G.scene.ramps

    if bounds.intersects G.player.bounds
      G.player.add_item self
      G.player.score += @score
      G.add_item_switch @switch if @switch
      G.scene.show_message "+ #{@score} pontos"
      G.play_sound :getItem
      @dead = true
    end
  end

  def use
    G.use_s_item @switch if @switch
  end
end
