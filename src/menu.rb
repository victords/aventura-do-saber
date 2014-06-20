require_relative 'global'
include AGL

class MenuComponent
	def initialize x, y, img
		@x = x
		@y = y
		@img = Res.img img
	end
	
	def move_to x, y, &on_finish
		@aim_x = x
		@aim_y = y
		@on_finish = Proc.new &on_finish
		@speed_x = (@aim_x - @x) / 8.0
		@speed_y = (@aim_y - @y) / 8.0
		@moving = true
	end
	
	def update
		if @moving
			@x += @speed_x
			@y += @speed_y
			dist_x = @aim_x - @x
			dist_y = @aim_y - @y
			if dist_x.round == 0 and dist_y.round == 0
				@x = @aim_x
				@y = @aim_y
				@moving = false
				@on_finish.call
			else
				@speed_x = dist_x / 8.0
				@speed_y = dist_y / 8.0
			end
		end
	end
	
	def draw
		@img.draw @x, @y, 0
	end
end

class Menu
	def initialize
		@bg = Res.img :bg_menu, true
#		@char1 = Res.img :other_marcus
#		@char2 = Res.img :other_milena
#		@selection = Sprite.new 133, 86, :other_selection, 2, 1
		@comps = 0
		@comp1 = MenuComponent.new -660, 0, :ui_menuComponent1
		@comp1.move_to(0, 0) { @comps += 1 }
		@comp2 = MenuComponent.new 800, 531, :ui_menuComponent2
		@comp2.move_to(409, 531) { @comps += 1 }
		
		@btn1 = Button.new(440, 555, G.font, "OK", :ui_btn1) {
			puts "OK"
		}
		@btn2 = Button.new(600, 555, G.font, "Voltar", :ui_btn1) {
			puts "Voltar"
		}
		@text_field = TextField.new 100, 260, G.big_font, :ui_textField, :ui_textCursor, "", 20, 13
	end
	
	def update
		@comp1.update
		@comp2.update
		if @comps == 2
			@btn1.update
			@btn2.update
			@text_field.update
#			@selection.animate [0, 1], 10
#			if KB.key_pressed?(Gosu::KbLeft) or KB.key_pressed?(Gosu::KbRight)
#				if @selection.x == 133; @selection.x = 435
#				else; @selection.x = 133; end
#			end
		end
	end
	
	def draw
		@bg.draw 0, 0, 0
		@comp1.draw
		@comp2.draw
		if @comps == 2
			G.big_font.draw "Qual é o seu nome?", 15, 5, 0, 1, 1, 0xff000000
			@btn1.draw
			@btn2.draw
			@text_field.draw
#			@selection.draw
#			@char1.draw 153, 106, 0
#			@char2.draw 474, 111, 0
		end
	end
end
