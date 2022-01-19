require 'pry-byebug'
require 'json'

class Game
  attr_accessor :guess_count, :guess_list, :word_key, :guess_array

  def initialize(guess_count, guess_list, word_key, guess_array, load_flag)
    @guess_count, @guess_list, @word_key, @guess_array, @load_flag = guess_count, guess_list, word_key, guess_array, load_flag
    if load_flag == 1
      start_game
    else
      start
    end
  end

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

  def new_game
    load_dictionary
    choose_random_word
    @guess_count = 6
    @guess_list = []
    start_game
  end

  def start_game
    loop do
      Display.show_game(@guess_array, @guess_count)
      guess = ask_guess
      check_guess(guess)
      check_victory
    end
  end

  def load_dictionary
    words = File.open('5desk.txt')
    dictionary = []
    words.each do |row|
      row = row.strip
      dictionary.push(row.downcase) if row.length.between?(5, 12)
    end
    dictionary
  end

  def choose_random_word
    dictionary = load_dictionary
    @word_key = dictionary[rand(0...dictionary.length)].split('')
    @guess_array = Array.new(@word_key.length, '_')
  end

  def load_game
    file_name = check_save
    if File.exist?(file_name)
      file = File.read(file_name)
      file_hash = JSON.parse(file, create_additions: true)
      json_create(file_hash)
    else
      Display.bad_load_name_prompt
      load_game
    end
  end

  def check_save
    if Dir.exist?('save_file')
      "save_file/#{Display.load_save_file_prompt}.json"
    else
      Display.no_saves_prompt
      new_game
    end
  end

  def save_game
    Dir.mkdir('save_file') unless Dir.exist?('save_file')
    Display.save_file_prompt
    ask_save_name
  end

  def ask_save_name
    file_name = gets.chomp
    if !file_name.match?(/\A[a-zA-Z]{2,20}\z/)
      Display.save_file_name_error_prompt
      save_game
    elsif File.exist?("save_file/#{file_name}.json")
      Display.save_file_exists_error_prompt
      save_game
    else
      File.open("save_file/#{file_name}.json", 'w') { |file| file.puts(to_json) }
      Display.save_goodbye_prompt
      exit
    end
  end

  def to_json(*args)
    {
      JSON.create_id => self.class.name,
      'guess_count' => guess_count,
      'guess_list' => guess_list,
      'word_key' => word_key,
      'guess_array' => guess_array,
      'load_flag' => 1
    }.to_json(*args)
  end

  def self.json_create(file_hash)
    new(file_hash['guess_count'], file_hash['guess_list'], file_hash['word_key'],
        file_hash['guess_array'], file_hash['load_flag'])
  end

  def ask_guess
    loop do
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

  def check_guess(guess)
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

  def check_victory
    if @guess_count.zero?
      Display.show_game(@word_key, @guess_count)
      victory_yes_no(Display.game_result_prompt('loss'), 'loss')
    elsif @guess_array.any?('_')
      return
    else
      Display.show_game(@word_key, @guess_count)
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
  def self.welcome_prompt
    puts "Welcome to Hangman!\nWould you like to play a new game ('new') or load a previous game ('load')?"
    gets.chomp
  end

  def self.load_prompt
    puts "Please enter the name of the game you would like to load:"
  end
  
  def self.show_game(guess_array, guess_count)
    puts "\n#{guess_array.join(' ')}"
    puts "\nGuesses remaining: #{guess_count}"
  end

  def self.guess_prompt
    puts "Type 'save' to save game and exit.  Otherwise, please guess a letter:"
    gets.chomp
  end

  def self.unknown_start_prompt
    puts "Sorry, I don't understand. Type 'new' to start a new game, and type 'load' to load a previous game."
  end

  def self.load_error_prompt
    puts "Sorry, that is not the name of a game I have saved.  Please try again."
  end

  def self.used_letter_prompt(letter)
    puts "Sorry, '#{letter}' has already been guessed. Please choose a different letter:"
  end

  def self.incorrect_letter_prompt
    puts "Sorry, you must type a single letter.  No digits or special characters allowed."
  end

  def self.save_exit_prompt(save_name)
    puts "Thank you for playing! You can pick up where you left off by typing 'load' and '#{save_name}' when you come back"
  end

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

  def self.save_file_prompt
    puts "Please enter a filename for the save that is between 2 and 20 letters"
  end

  def self.save_file_name_error_prompt
    puts "Error: name must be between 2 and 20 letters (no numbers or special characters)"
  end

  def self.save_file_exists_error_prompt
    puts "Error: file name already used"
  end

  def self.save_goodbye_prompt
    puts "Game saved. 'Til next time!"
  end

  def self.load_save_file_prompt
    puts "Please enter the name of the save file"
    gets.chomp
  end

  def self.no_saves_prompt
    puts "There are no save files, starting new game."
  end

  def self.bad_load_name_prompt
    puts "That is not the name of a save file"
  end
end

Game.new(0, 0, 0, 0, 0)
