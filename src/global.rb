require 'minigl'
include AGL

class G
	def self.initialize
		@@win = Game.window
		@@font = Res.font :UbuntuLight, 20
		@@big_font = Res.font :UbuntuLight, 54
		@@state = :menu
		
		@@menu = Menu.new
	end
	
	def self.start_game char_index
		@@state = :game
		character =
			case char_index
			when 0 then :marcus
			when 1 then :milena
			end
		@@player = Character.new character
		@@scene = Scene.new 1, @@player, 1
	end
	
	def self.win; @@win; end
	def self.font; @@font; end
	def self.big_font; @@big_font; end
	def self.state; @@state; end
	def self.menu; @@menu; end
	def self.scene; @@scene; end
end
