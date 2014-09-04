require 'minigl'
require_relative 'player'
include AGL

class G
	def self.initialize
		@@win = Game.window
		@@font = Res.font :UbuntuLight, 20
		@@med_font = Res.font :UbuntuLight, 32
		@@big_font = Res.font :UbuntuLight, 54
		@@effects = File.open("data/text/fx.txt").readlines
		@@state = :menu
		
		@@menu = Menu.new
	end
	
	def self.start_game type, name, char
		@@state = :game
		@@player = Player.new name, char, {}
		@@scene = Scene.new 1, 1
	end
	
	def self.win; @@win; end
	def self.font; @@font; end
	def self.med_font; @@med_font; end
	def self.big_font; @@big_font; end
	def self.effects; @@effects; end
	def self.state; @@state; end
	
	def self.menu; @@menu; end
	def self.player; @@player; end
	def self.scene; @@scene; end
end
