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
		Dir["data/img/bg/#{type}Intro*"].sort.each do |f|
			@scenes << Gosu::Image.new(G.win, f, false)
		end
		@texts = []
		File.open("data/text/#{type}.txt").each do |l|
			s = l.chomp.gsub("\\n", "\n")
			@texts << XText.new(s, 10, 600 - s.split("\n").size * 36, 0, true)
		end
		
		@cur_scene = 0
		@rect_alpha = 255
		@transition = 0
	end
	
	def update
		@texts.each { |t| t.update_alpha }
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
				end
			end
		else
			d_x = (100 - @texts[@cur_scene].x) / 50.0
			@texts[@cur_scene].x += d_x if d_x.round(2) > 0
			@transition = 1 if KB.key_pressed? Gosu::KbA
		end
		false
	end
	
	def draw
		@scenes[@cur_scene].draw 0, 0, 0
		@texts[@cur_scene].draw
		if @transition
			color = (@rect_alpha << 24)
			G.win.draw_quad 0, 0, color,
			                800, 0, color,
			                800, 600, color,
			                0, 600, color, 1
		end
	end
end
