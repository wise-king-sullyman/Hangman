# frozen_string_literal: true

require 'yaml'

# Responsible for drawing the different stages of the hangmans gallows
class Gallows
  def initialize
    @hangman_stages = File.readlines 'hangman_stages.txt'
    @stage = 0
  end

  def draw
    stage_times_offset = @stage * 7
    puts @hangman_stages.slice(stage_times_offset..stage_times_offset + 6)
  end

  def next_stage
    @stage += 1
  end

  def dropsies?
    true if @stage == 6
  end
end

# Responsible for the generation and checking of the secret word
class Secret
  def initialize
    dictionary = File.readlines('5desk.txt').select do |word|
      word.chomp.length > 5 && word.chomp.length < 12
    end
    @word = dictionary.sample.chomp.downcase
    @blank_char = '_ '
  end

  def reveal
    @word
  end

  def matches(guess, previous_feedback)
    new_feedback = @word.split('').map do |char|
      char == guess ? char : @blank_char
    end
    combined_feedback = combine_feedback(new_feedback, previous_feedback)
    combined_feedback
  end

  def blank_word
    @word.split('').map { |char| char.replace @blank_char }
  end

  def solved?(feedback)
    true if @word.split('') == feedback
  end

  private

  def combine_feedback(new_feedback, previous_feedback)
    combined_feedback = new_feedback.map.with_index do |char, index|
      if char != @blank_char
        char
      elsif previous_feedback[index] != @blank_char
        previous_feedback[index]
      else
        @blank_char
      end
    end
    combined_feedback
  end
end

# Responsible for executing the actions of the player, namely guessing
class Player
  def guess
    puts 'Enter guess now'
    this_guess = gets.chomp.downcase
    return this_guess if valid?(this_guess)

    puts 'Guess must be one letter'
    guess
  end

  private

  def valid?(guess_to_check)
    return true if guess_to_check.size == 1 && guess_to_check.match?(/[a-z]/)

    true if guess_to_check == 'save'
  end
end

# Responsible for the operation of the game mechanics
class Game
  def initialize
    @secret = Secret.new
    @gallows = Gallows.new
    @player = Player.new
    @previous_feedback = @secret.blank_word
    @incorrect_guesses = []
    @file_name = 'hangman_save.yaml'
  end

  def play
    ask_to_load_game if File.exist?(@file_name)
    puts 'Save and quit any round by entering "save" in place of your guess'
    print_feedback(@previous_feedback)
    game_loop
    game_over
  end

  private

  def game_loop
    until @gallows.dropsies? || @secret.solved?(@previous_feedback)
      guess = @player.guess
      save_game if guess == 'save'
      new_feedback = @secret.matches(guess, @previous_feedback)
      wrong_guess(guess) if new_feedback == @previous_feedback
      print_feedback(new_feedback)
      @previous_feedback = new_feedback
    end
  end

  def print_feedback(feedback)
    puts feedback.join(' ')
    puts "Incorrect Guesses: #{@incorrect_guesses.join(' ')}"
    @gallows.draw
  end

  def wrong_guess(guess)
    @gallows.next_stage 
    @incorrect_guesses.push(guess)
  end

  def save_game
    current_state = {
      secret: @secret,
      gallows: @gallows,
      previous_feedback: @previous_feedback,
      incorrect_guesses: @incorrect_guesses
    }
    File.open(@file_name, 'w') { |file| file.write(current_state.to_yaml) }
    puts 'Game saved. Exiting now.'
    abort
  end

  def ask_to_load_game
    puts 'Save game detected. Load previous game? y/n'
    load_game if gets.chomp == 'y'
  end

  def load_game
    save = YAML.load_file(@file_name)
    @secret = save[:secret]
    @gallows = save[:gallows]
    @previous_feedback = save[:previous_feedback]
    @incorrect_guesses = save[:incorrect_guesses]
  end

  def game_over
    if @secret.solved?(@previous_feedback)
      puts('You won!')
    else
      puts('You lose you big looser!')
      puts "The secret word was #{@secret.reveal}"
    end

    return unless File.exist?(@file_name)

    puts 'Would you like to delete the existing savegame? y/n'
    File.delete(@file_name) if gets.chomp == 'y'
  end
end

game = Game.new
game.play
