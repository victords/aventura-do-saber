require_relative 'lib/game_object'
include AGL

class Character < GameObject
	def initialize name
		w =
			case name
			when :marcus then 44
			when :milena then 37
			end
		super 0, 0, w, 115, name, Vector.new(-8, -5), 3, 2
		@anim_indices_left_stop = [0]
		@anim_indices_left = [0, 1, 0, 2]
		@anim_indices_right_stop = [3]
		@anim_indices_right = [3, 4, 3, 5]
		@anim_interval = 9
	end
	
	def update scene
		animate @anim_indices, @anim_interval
		
		forces = Vector.new 0, 0
		
		# teclas esquerda e direita
		forces.x -= 0.4 if KB.key_down? Gosu::KbLeft
		forces.x += 0.4 if KB.key_down? Gosu::KbRight
		
		# atrito do solo
		forces.x -= 0.1 * speed.x if @bottom
		
		# tecla para cima (pulo)
		forces.y -= 15 if KB.key_down? Gosu::KbUp and @bottom
		
		move forces, scene.obsts, scene.ramps
	end
	
	def set_position entry
		@x = entry[:pos].x
		@y = entry[:pos].y
		@speed.x = @speed.y = 0
		
		@anim_indices = (entry[:dir] == :l ? @anim_indices_left_stop : @anim_indices_right_stop)
		set_animation @anim_indices[0]
	end
end
