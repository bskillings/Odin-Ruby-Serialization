require "yaml"

class Hangman

	def initialize
		@word = pick_a_word
		#puts @word
		@game_won = false
		@draw_man_array = [" O \n", "\\", "|", "/ \n", " | \n", "/ ", "\\", " Last Chance!"]
		play_game
	end

	def play_game#go through turns
		@wrong_guesses = []
		@current_word_status = Array.new(@word.length, " _ ")
		draw_word
		while @game_won == false && @wrong_guesses.length < 8
			puts "guess a letter, or type \"game\" to save, load, or exit"
			action = gets.chomp.downcase
			if action == "game"
				game_actions
			else
				take_a_turn(action)
			end
			draw_man
			draw_word
		end
		puts "You win!" if @game_won
		puts "You Lose! Too many guesses!" if @wrong_guesses.length >= 8 
		puts "The word was #{@word}"
	end

	def take_a_turn(guess)
		compare_word(guess)
		@game_won = check_if_game_won
		end

	def pick_a_word #choose a word, check for suitability
		word = ""
		while word.length < 5 || word.length > 12
			how_many_words = 0
			File.open("text.txt").each {|line| how_many_words += 1}
			which_word = rand(how_many_words)
			File.open("text.txt", "r") do |line|
				while which_word > 0
					which_word -= 1
					word = line.gets.strip.downcase
				end
			end
		end
		return word
	end

	def draw_word #prints out word blanks with filled in letters
		puts " "
		puts "#{@current_word_status.join}  wrong: #{@wrong_guesses.join}"
		puts " "
	end

	def get_guess #gets guess from player
		puts "guess a letter"
		letter = gets.chomp.downcase
	end

	def compare_word(guess) # compares guess to chosen word
		chosen_word_array = @word.split("")
		guess_is_wrong = true

		chosen_word_array.each_with_index do |letter, index|#compare to each element of array
			if chosen_word_array[index] == guess
				@current_word_status[index] = " #{letter} "
				guess_is_wrong = false
			end
		end
		if guess_is_wrong == true
			@wrong_guesses.push(" #{guess}")
		end
	end

	def draw_man #incomplete / optional
		puts " "
		i = 0
		while i < @wrong_guesses.length
			print @draw_man_array[i]
			i += 1
		end
		puts " "
	end

	def check_if_game_won
		no_blanks = true
		@current_word_status.each do |letter|
			if letter == " _ "
				no_blanks = false
			end
		end
		return no_blanks
	end

	def game_actions
		puts "Type \"save\", \"load\", or \"exit\""
		action = gets.chomp.downcase
		case action
		when "save"
			save_game
		when "load"
			load_game
		when "exit"
			puts "Please press Ctrl-C to exit"
			dummy = gets
		else
			puts "Did not understand, returning to game"
		end
	end

	def save_game 
		puts "Name your savegame"
		filename = gets.chomp
		save_array = Array.new [@word, @current_word_status, @wrong_guesses]
		File.open("#{filename}.yaml", "w") {|f| f.write(YAML::dump(save_array))}
		puts "#{filename}.yaml saved"
	end

	def load_game
		puts "Type the name of your savegame"
		filename = gets.chomp
		file_to_load = File.new("#{filename}.yaml")
		load_array = YAML::load(file_to_load)
		puts "#{filename}.yaml loaded"
		@word = load_array[0]
		@current_word_status = load_array[1]
		@wrong_guesses = load_array[2]
	end
end

hangman = Hangman.new