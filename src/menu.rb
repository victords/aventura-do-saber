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
		@comps = 0
		@comp1 = MenuComponent.new -660, 0, :ui_menuComponent1
		@comp1.move_to(0, 0) { @comps += 1 }
		@comp2 = MenuComponent.new 800, 531, :ui_menuComponent2
		@comp2.move_to(409, 531) { @comps += 1 }
		
		@btn = Button.new(500, 555, G.font, "Test", :ui_btn1) {
			puts "clicou"
		}
	end
	
	def update
		@comp1.update
		@comp2.update
		if @comps == 2
			@btn.update
		end
	end
	
	def draw
		@bg.draw 0, 0, 0
		@comp1.draw
		@comp2.draw
		if @comps == 2
			@btn.draw
		end
	end
end
