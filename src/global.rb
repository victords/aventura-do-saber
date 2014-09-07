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
		@@scenes = {}
		
		class_variables.each do |v|
			define_singleton_method(v.to_s[2..-1]) { class_variable_get v }
		end
		
		@@menu = Menu.new
	end
	
	def self.start_game type, name, char, continue
		if continue
			puts "Continuando: #{name}"
			f = File.open("data/save/#{name}")
			s = f.readline.split(',').map { |s| s.to_i }
			@@scenes[:math] = s[0]
			@@scenes[:port] = s[1]
			@@scenes[:logic] = s[2]
			@@scenes[:all] = s[3]
			s = f.readline.split(',').map { |s| s.to_i }
			s.each { |sw| @@switches << sw }
		else
			puts "Novo jogo: #{name}"
		end
		
		@@state = :game
		@@player = Player.new name, char, {}
		@@scene = Scene.new type, G.scenes[type], 1
	end
end
