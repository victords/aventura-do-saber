require 'gosu'
require 'minigl'
include AGL

class G
	def self.initialize
		@@win = Game.window
		@@font = Gosu::Font.new @@win, "data/font/Ubuntu-L.ttf", 20
	end
	
	def self.win; @@win; end
	def self.font; @@font; end
end
