# encoding: utf-8

include AGL

class Intro
  def initialize type
    type =
      case type
      when 0 then "math"
      when 1 then "port"
      when 2 then "logic"
      else        "all"
      end
    @scenes = []
    Dir["#{Res.prefix}img/bg/#{type}Intro*"].sort.each do |f|
      id = f.split('/')[-1].chomp(".png")
      @scenes << Sprite.new(-100, -75, "bg_#{id}")
    end
    @texts = []
    File.open("#{Res.prefix}text/#{type}.txt").each do |l|
      s = l.chomp.gsub("\\n", "\n")
      @texts << XText.new(s, 10, 600 - s.split("\n").size * 36, 0, G.med_font, true)
    end
    @hint = XText.new "Pressione 'A' ou clique para continuar...", 10, 5, 0x00ffff

    @scale = 1
    @cur_scene = 0
    @rect_alpha = 255
    @transition = 0
  end

  def update
    @texts.each { |t| t.update_alpha }
    @hint.update_alpha
    if @transition == 0
      @rect_alpha -= 5
      if @rect_alpha == 0
        @transition = nil
        @texts[@cur_scene].fade_in
      end
    elsif @transition == 1
      @rect_alpha += 5
      if @rect_alpha == 255
        @cur_scene += 1
        if @cur_scene == @scenes.length
          return true
        else
          @transition = 0
          @scale = 1
          @hint.alpha = 0
        end
      end
    else
      d_x = (100 - @texts[@cur_scene].x) / 50.0
      @texts[@cur_scene].x += d_x if d_x.round(2) > 0
      if @scale > 0.8
        @scale *= 0.9995
        @scenes[@cur_scene].x = (800 - (@scale * 1000)) / 2
        @scenes[@cur_scene].y = (600 - (@scale * 750)) / 2
        @hint.fade_in if @scale <= 0.8
      end
      @transition = 1 if KB.key_pressed? Gosu::KbA or Mouse.button_pressed? :left
    end
    false
  end

  def draw
    @scenes[@cur_scene].draw nil, @scale, @scale
    @texts[@cur_scene].draw
    @hint.draw
    if @transition
      color = (@rect_alpha << 24)
      G.win.draw_quad 0, 0, color,
                      800, 0, color,
                      800, 600, color,
                      0, 600, color, 1
    end
  end
end
