# encoding: utf-8

Series = Struct.new :name, :color, :data

class Chart
  def initialize x, y, w, h, marker_size = 4, categories = nil
    @x = x
    @y = y
    @w = w
    @h = h
    @marker_size = marker_size
    @categories = categories
  end

  def set_series series
    @series = series
    @x_max = 0
    series.each { |s| @x_max = s.data.length if s.data.length > @x_max }
    @y_max = 0
    series.each { |s| @y_max = s.data.max if s.data.max and s.data.max > @y_max }
  end

  def update; end

  def draw alpha
    a_black = (alpha << 24)
    @series.each_with_index do |s, j|
      prev_x = prev_y = nil
      color = a_black | s.color
      s.data.each_with_index do |d, i|
        x = (@x + (i + 0.5) * @w / @x_max).round
        y = (@y + @h - (@h * d / (@y_max + 1.0))).round
        x_ = x - @marker_size / 2
        y_ = y - @marker_size / 2
        G.win.draw_quad x_, y_, color,
                        x_ + @marker_size, y_, color,
                        x_ + @marker_size, y_ + @marker_size, color,
                        x_, y_ + @marker_size, color, 0
        G.font.draw d.to_s, x, y - 18, 1, 1, 1, a_black
        if i > 0
          G.win.draw_line prev_x, prev_y, color,
                          x, y, color, 0
        end
        prev_x = x
        prev_y = y
      end
      top = @y + (@h - (25 * @series.length - 10)) / 2
      G.win.draw_quad @x + @w + 15, top + j * 25, color,
                      @x + @w + 30, top + j * 25, color,
                      @x + @w + 30, top + 15 + j * 25, color,
                      @x + @w + 15, top + 15 + j * 25, color, 1
      G.font.draw s.name, @x + @w + 35, top - 3 + j * 25, 1, 1, 1, a_black
    end
    if @categories
      @categories.each_with_index do |c, i|
        x = (@x + (i + 0.5) * @w / @x_max).round
        G.font.draw_rel c, x, @y + @h + 5, 1, 0.5, 0, 1, 1, a_black
      end
    end
    G.win.draw_line @x, @y, a_black,
                    @x, @y + @h, a_black, 1
    G.win.draw_line @x, @y + @h, a_black,
                    @x + @w, @y + @h, a_black, 1
  end
end
