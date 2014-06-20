require 'gosu'
require 'minigl'
include AGL

class G
	def self.initialize
		@@win = Game.window
		@@font = Res.font :UbuntuLight, 20
		@@big_font = Res.font :UbuntuLight, 54
	end
	
	def self.win; @@win; end
	def self.font; @@font; end
	def self.big_font; @@big_font; end
end
