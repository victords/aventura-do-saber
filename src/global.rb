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
		@@switches = []
		@@state = :menu
		@@menu = nil
		@@player = nil
		@@scene = nil
		
		class_variables.each do |v|
			define_singleton_method(v.to_s[2..-1]) { class_variable_get v }
		end
		
		@@menu = Menu.new
	end
	
	def self.start_game type, name, char, continue
		if continue
			puts "Continuando: #{name}"
			puts File.open("data/save/#{name}").read
		else
			puts "Novo jogo: #{name}"
		end
		
		@@state = :game
		@@player = Player.new name, char, {}
		@@scene = Scene.new 1, 1
	end
end
