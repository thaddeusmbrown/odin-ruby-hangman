require 'pry-byebug'

class Game

  # welcome player and start a new game from scratch
  def start
    loop do
      answer = Display.welcome_prompt
      if answer == 'new'
        new_game
      elsif answer == 'load'
        load_game
      else
        Display.unknown_start_prompt
      end
    end
  end
    
  # start a new game
  def new_game
    load_dictionary
    choose_random_word
    @guess_count = 6
    @guess_list = []
    loop do
      Display.show_game(@guess_array, @guess_count)
      guess = get_guess
      check_guess(guess)
      check_victory
    end
  end

  # load dictionary
  def load_dictionary
    words = File.open('5desk.txt')
    dictionary = []
    words.each do |row|
      row = row.strip
      if row.length.between?(5, 12)
        dictionary.push(row.downcase)
      end
    end
    dictionary
  end

  def choose_random_word
    dictionary = load_dictionary
    @word_key = dictionary[rand(0...dictionary.length)].split('')
    @guess_array = Array.new(@word_key.length, '_')
  end


  # load a previous game
  def load_game
    # load word key, guess array, and guesses remaining

    # display state

  end
  # save a game and exit
  def save_game
    # say goodbye

  end

  # input guess
  def get_guess
    loop do
      # binding.pry
      guess = Display.guess_prompt
      if guess == 'save'
        save_game
      elsif guess.length != 1 || (guess.match(/[A-Za-z]/) ? false : true)
        Display.incorrect_letter_prompt
      elsif @guess_array.include?(guess.downcase) || @guess_list.include?(guess.downcase)
        Display.used_letter_prompt(guess.downcase)
      else
        @guess_list.push(guess)
        return guess.downcase
      end
    end
  end

  # check guess
  def check_guess(guess)
    # binding.pry
    if @word_key.include? guess
      @word_key.each_with_index do |letter, index|
        if letter == guess
          @guess_array[index] = guess
        end
      end
    else
      @guess_count -= 1
    end
  end

  # check victory
  def check_victory
    if @guess_count == 0
      victory_yes_no(Display.game_result_prompt('loss'), 'loss')
    elsif @guess_array.any?('_')
      return
    else
      victory_yes_no(Display.game_result_prompt('win'), 'win')
    end
  end

  def victory_yes_no(answer, result)
    if answer == 'y'
      new_game
    elsif answer == 'n'
      exit
    else
      Display.yes_no_error_prompt
      victory_yes_no(Display.game_result_prompt(result))
    end
  end

end

class Display

  # welcome
  def self.welcome_prompt
    puts "Welcome to Hangman!\nWould you like to play a new game ('new') or load a previous game ('load')?"
    gets.chomp
  end

  # load previous game
  def self.load_prompt
    puts "Please enter the name of the game you would like to load:"
  end
  
  # display game state (word guess array and guesses remaining)
  def self.show_game(guess_array, guess_count)
    puts "\n#{guess_array.join(' ')}"
    puts "\nGuesses remaining: #{guess_count}"
  end

  # guess letter prompt
  def self.guess_prompt
    puts "Type 'save' to save game and exit.  Otherwise, please guess a letter:"
    gets.chomp
  end

  # unknown game start prompt error
  def self.unknown_start_prompt
    puts "Sorry, I don't understand. Type 'new' to start a new game, and type 'load' to load a previous game."
  end

  # invalid load file name prompt error
  def self.load_error_prompt
    puts "Sorry, that is not the name of a game I have saved.  Please try again."
  end

  # used letter error prompt
  def self.used_letter_prompt(letter)
    puts "Sorry, '#{letter}' has already been guessed. Please choose a different letter:"
  end

  # incorrect letter error prompt
  def self.incorrect_letter_prompt
    puts "Sorry, you must type a single letter.  No digits or special characters allowed."
  end

  # save game exit prompt
  def self.save_exit_prompt(save_name)
    puts "Thank you for playing! You can pick up where you left off by typing 'load' and '#{save_name}' when you come back"
  end

  # game result and play again prompt
  def self.game_result_prompt(victory_condition)
    if victory_condition == 'win'
      puts "Victory! Would you like to play again? (y/n)"
      gets.chomp
    else
      puts "Defeat! Would you like to play again? (y/n)"
      gets.chomp
    end
  end

  def self.yes_no_error_prompt
    puts "Error: must type 'y' for yes or 'n' for no"
  end

end

game = Game.new

game.start