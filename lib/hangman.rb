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
  # load the dictionary and choose a random word

    # save the word as the key to check against

    # save the word again as a masked array to display to user

  # input guess

  # check guess

  # update word array, guess array, check for result, and display game state

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
    puts guess_array.join(' ')
    puts "Guesses remaining: #{guess_count}"
  end

  # guess letter prompt
  def self.guess_prompt
    puts "Please guess a letter"
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

end

game = Game.new

game.start