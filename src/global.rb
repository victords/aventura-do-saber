require 'minigl'
require_relative 'player'
require_relative 'intro'
include AGL

class G
	def self.initialize hints, sounds, music
		@@win = Game.window
		@@full_screen = @@win.fullscreen?
		@@hints = hints
		@@sounds = sounds
		@@music = music
		
		@@font = Res.font :UbuntuLight, 20
		@@med_font = Res.font :UbuntuLight, 32
		@@big_font = Res.font :UbuntuLight, 54
		f = File.open("data/text/fx.txt")
		@@effects = f.readlines
		f.close
		@@items = {}
		File.open("data/text/items.txt").each do |l|
			key = l.chomp!.split(',')[0].to_sym
			@@items[key] = l
		end
		@@s_items = {}
		File.open("data/text/s_items.txt").each do |l|
			l = l.chomp.split
			@@s_items[l[0].to_i] = l[1]
		end
		@@switches = nil
		@@state = :menu
		
		@@menu = nil
		@@player = nil
		@@scene = nil
		@@scenes = nil
		@@c_answers = nil
		@@w_answers = nil
		
		class_variables.each do |v|
			define_singleton_method(v.to_s[2..-1]) { class_variable_get v }
		end
		
		@@temp_options = [
			(@@full_screen ? 1 : 0),
			(hints ? 1 : 0),
			(sounds ? 1 : 0),
			(music ? 1 : 0)
		]
		@@cur_music = nil
		@@menu = MainMenu.new
	end
	
	def self.set_option o, v
		@@temp_options[o] = (v ? 1 : 0)
	end
	
	def self.save_options
		@@full_screen = (@@temp_options[0] == 1)
		@@hints = (@@temp_options[1] == 1)
		@@sounds = (@@temp_options[2] == 1)
		@@music = (@@temp_options[3] == 1)
		unless @@music
			@@cur_music.stop unless @@cur_music.nil?
			@@cur_music = nil
		end
		f = File.open("data/save/_config", "w")
		f.write @@temp_options.join(',')
		f.close
	end
	
	def self.start_game type, name, char, continue
		@@game_type = type
		@@player = Player.new name, char
		@@item_switches = []
		@@menu = nil
		if continue
			Res.clear
			UI.initialize
			f = File.open("data/save/#{name}")
			@@player.score = f.readline.to_i
			@@scenes = f.readline.split(',').map { |s| s.to_i }
			@@scenes[type] = 1 if @@scenes[type] == 0
			@@c_answers = []
			all_c_answers = f.readline.chomp.split('|', -1)
			all_c_answers.each { |a| @@c_answers << a.split(',').map { |s| s.to_i } }
			@@c_answers[type] << (@@c_answers[type].empty? ? 0 : @@c_answers[type][-1])
			@@w_answers = f.readline.split(',').map { |s| s.to_i }
			@@switches = f.readline.split(',').map { |s| s.to_i }
			s = f.readline.chomp.split(',').map { |s| s.to_i }
			s.each do |sw|
				item_type = @@s_items[sw].split(',')[2].to_sym
				info = @@items[item_type]
				eval "@@player.add_item Item.new(0, 0, :#{info}, sw)"
				@@item_switches << sw
			end
			f.close
			@@state = :game
			@@scene = Scene.new type, @@scenes[type], 0
		else
			@@scenes = [0, 0, 0, 0]
			@@scenes[type] = 1
			@@c_answers = [[], [], [], []]
			@@c_answers[type] << 0
			@@w_answers = [0, 0, 0, 0]
			@@switches = []
			@@state = :intro
			@@intro = Intro.new type
		end
	end
	
	def self.add_item_switch sw
		@@switches << sw
		@@item_switches << sw
	end
	
	def self.use_s_item sw
		@@item_switches.delete sw
	end
	
	def self.correct_answer
		@@c_answers[@@game_type][-1] += 1
	end
	
	def self.wrong_answer
		@@w_answers[@@game_type] += 1
	end
	
	def self.play_music music
		return unless @@music
		if @@cur_music.nil? or @@cur_music != music
			@@cur_music.stop unless @@cur_music.nil?
			@@cur_music = music
			@@cur_music.play
		end
	end
	
	def self.set_scene scene, entry
		@@state = :transition
		@@next_scene = scene
		@@next_entry = entry
		@@transition_alpha = 0
	end
	
	def self.update_intro
		if @@intro.update
			Res.clear
			UI.initialize
			@@scene = Scene.new @@game_type, 1, 0
			@@state = :transition
			@@transition_alpha = 255
			@@next_scene = nil
		end
	end
	
	def self.draw_intro
		@@intro.draw
	end
	
	def self.update_transition
		if @@next_scene
			@@transition_alpha += 17
			if @@transition_alpha == 255
				Res.clear
				UI.initialize
				@@scene = Scene.new @@game_type, @@next_scene, @@next_entry
				@@scenes[@@game_type] = @@next_scene
				@@next_scene = @@next_entry = nil
			end
		else
			@@transition_alpha -= 17
			@@state = :game if @@transition_alpha == 0
		end
	end
	
	def self.draw_transition
		color = (@@transition_alpha << 24)
		@@win.draw_quad 0, 0, color,
		                800, 0, color,
		                800, 600, color,
		                0, 600, color, 0
	end
	
	def self.open_menu
		@@menu = SceneMenu.new @@game_type
		@@state = :paused
	end
	
	def self.resume_game
		@@menu = nil
		@@state = :game
	end
	
	def self.back_to_menu
		@@scene = nil
		Res.clear
		save_game
		@@menu = MainMenu.new
		@@state = :menu
	end
	
	def self.save_game
		f = File.open("data/save/#{@@player.name}", "w")
		f.write @@player.score.to_s + "\n"
		f.write @@scenes.join(',') + "\n"
		all_c_answers = []
		@@c_answers.each { |a| all_c_answers << a.join(',') }
		f.write all_c_answers.join('|') + "\n"
		f.write @@w_answers.join(',') + "\n"
		f.write @@switches.join(',') + "\n"
		f.write @@item_switches.join(',') + "\n"
		f.close
	end
	
	def self.quit_game
		@@win.close
	end
end
