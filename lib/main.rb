require 'sinatra/base'
require 'sinatra/flash'
require_relative 'game'
require_relative 'player'
require_relative 'enemy'
require_relative 'weapon'


class RPSLS < Sinatra::Base

	set :views, Proc.new {File.join(root, '..', 'views')}
	set :public_folder, 'public'

	enable :sessions

	GAME = Game.new

	get '/' do
	    erb :index
	end

	post '/create_player' do
		# flash[:error] = "You must enter your name to continue."
		# redirect '/' if params['name']==""
	  	@name = params['name']
	  	session[:name] = @name
	  	# player = Player.new
	  	# player.name = @name
	  	# GAME.add_player(player)
	  	# if GAME.has_two_players?
	  	# 	session[:player] = :player2
	  	# else
	  	# 	session[:player] = :player1
	  	# end
	  	puts GAME.inspect
		erb :index
	end

	post '/opponent_route' do
		redirect '/opponent_computer' if params['opponent']=="super_computer"
		redirect '/opponent_human'
	end

	get '/opponent_computer' do
		player = Player.new
	  	player.name = session[:name]
	  	GAME.add_player(player)
		enemy = Enemy.new
		GAME.add_player(enemy)
		redirect '/choose_weapon'
	end


	get '/opponent_human' do
		player = Player.new
	  	player.name = session[:name]
	  	GAME.add_player(player)
	  	if GAME.has_two_players?
	  		session[:player] = :player2
	  	else
	  		session[:player] = :player1
	  	end
		redirect '/waiting_for_player' if !GAME.has_two_players?
		redirect '/choose_weapon'
		# @name = session[:name]
	end

	get '/choose_weapon' do
		@opponent = GAME.player2.name if GAME.player2.is_a?(Enemy)
		@name = session[:name]

		erb :game_screen
	end

	get '/waiting_for_player' do
		redirect '/choose_weapon' if GAME.has_two_players?
		@name = session[:name]

		erb :waiting
	end

	post '/weapon_vs_computer' do
		GAME.player1.weapon = params['weapon']
		GAME.get_computer_weapon
		puts GAME.inspect

		erb :result
	end

	post '/weapon_vs_human' do
		if session[:player]==:player1
			GAME.player1.weapon = params['weapon']
		else
			GAME.player2.weapon = params['weapon']
		end
		puts GAME.inspect

		redirect '/waiting_for_weapon' unless GAME.both_have_weapon?

		redirect '/result_vs_human'
	end

	get '/waiting_for_weapon' do
		redirect '/result_vs_human' if GAME.both_have_weapon?
		@name = session[:name]

		erb :waiting
	end

	get '/result_vs_human' do
		puts GAME.inspect

		erb :result
	end

	# start the server if ruby file executed directly
	run! if app_file == $0
end