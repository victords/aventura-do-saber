require_relative 'menu'
require_relative 'scene'
include AGL

class MyGame < Gosu::Window
	def initialize full_screen, hints, sounds, music
		super 800, 600, full_screen
		self.caption = "Aventura do Saber"
		
		Game.initialize self
		G.initialize hints, sounds, music
	end
	
	def needs_cursor?
		true
	end
	
	def update
		KB.update
		Mouse.update
		
		if G.state == :menu or G.state == :paused
			G.menu.update
		elsif G.state == :game
			if KB.key_pressed? Gosu::KbEscape; G.open_menu
			else; G.scene.update; end
		elsif G.state == :intro
			G.update_intro
		else
			G.update_transition
		end
	end
	
	def draw
		if G.state == :menu or G.state == :paused
			G.scene.draw if G.state == :paused
			G.menu.draw
		elsif G.state == :intro
			G.draw_intro
		else
			G.scene.draw
			UI.draw
			G.draw_transition if G.state == :transition
		end
	end
end

f = File.open("data/save/_config")
config = f.read.chomp.split(',')
full_screen = (config[0] == '1')
hints = (config[1] == '1')
sounds = (config[2] == '1')
music = (config[3] == '1')
f.close

game = MyGame.new full_screen, hints, sounds, music
game.show

