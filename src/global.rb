require 'minigl'
require_relative 'player'
include AGL

class G
	def self.initialize hints, sounds, music
		@@win = Game.window
		@@hints = hints
		@@sounds = sounds
		@@music = music
		
		@@font = Res.font :UbuntuLight, 20
		@@med_font = Res.font :UbuntuLight, 32
		@@big_font = Res.font :UbuntuLight, 54
		f = File.open("data/text/fx.txt")
		@@effects = f.readlines
		f.close
		@@switches = []
		@@state = :menu
		
		@@menu = nil
		@@player = nil
		@@scene = nil
		@@scenes = {}
		
		class_variables.each do |v|
			define_singleton_method(v.to_s[2..-1]) { class_variable_get v }
		end
		
		@@temp_options = [
			(@@win.fullscreen? ? 1 : 0),
			(hints ? 1 : 0),
			(sounds ? 1 : 0),
			(music ? 1 : 0)
		]
		@@menu = Menu.new
	end
	
	def self.start_game type, name, char, continue
		if continue
			f = File.open("data/save/#{name}")
			s = f.readline.split(',').map { |s| s.to_i }
			@@scenes[:math] = s[0]
			@@scenes[:port] = s[1]
			@@scenes[:logic] = s[2]
			@@scenes[:all] = s[3]
			s = f.readline.split(',').map { |s| s.to_i }
			s.each { |sw| @@switches << sw }
			f.close
		end
		
		@@state = :game
		@@player = Player.new name, char, {}
		UI.initialize
		@@scene = Scene.new type, G.scenes[type], 1
	end
	
	def self.set_option o, v
		@@temp_options[o] = (v ? 1 : 0)
	end
	
	def self.save_options
		@@hints = (@@temp_options[1] == 1)
		@@sounds = (@@temp_options[2] == 1)
		@@music = (@@temp_options[3] == 1)
		f = File.open("data/save/_config", "w")
		f.write @@temp_options.join(',')
		f.close
	end
	
	def self.quit_game
		@@win.close
	end
end
