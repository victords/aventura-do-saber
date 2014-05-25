require 'minigl'
include AGL

class Character < GameObject
	def initialize name
		w =
			case name
			when :marcus then 44
			when :milena then 37
			end
		super 0, 0, w, 115, name, Vector.new(-8, -5), 3, 2
		@max_speed.x = 10; @max_speed.y = 20
		
		@anim_indices_left = [0, 1, 0, 2]
		@anim_indices_right = [3, 4, 3, 5]
		#@anim_interval = 9
	end
	
	def update scene
		forces = Vector.new 0, 0
		
		if KB.key_down? Gosu::KbLeft
			set_direction :left if @facing_right
			forces.x -= @bottom ? 0.3 : 0.05
		elsif @speed.x < 0
			forces.x -= 0.1 * @speed.x
		end
		if KB.key_down? Gosu::KbRight
			set_direction :right if not @facing_right
			forces.x += @bottom ? 0.3 : 0.05
		elsif @speed.x > 0
			forces.x -= 0.1 * @speed.x
		end
		if @bottom
			if @speed.x != 0
				animate @anim_indices, 30 / @speed.x.abs
			elsif @facing_right
				set_animation 3
			else
				set_animation 0
			end
			if KB.key_pressed? Gosu::KbUp
				forces.y -= 13.7 + 0.4 * @speed.x.abs
#				if @facing_right; set_animation 3
#				else; set_animation 8; end
			end
		end
		
		move forces, scene.obsts, scene.ramps
	end
	
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
	
	def set_position entry
		@x = entry.x
		@y = entry.y
		@speed.x = @speed.y = 0
		
		@facing_right = (entry.dir != :l)
		@anim_indices = (entry.dir == :l ? @anim_indices_left : @anim_indices_right)
		set_animation @anim_indices[0]
	end
end
