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
    dictionary = File.readlines('5desk.txt').select { |word| word.chomp.length > 5 && word.chomp.length < 12 }
    @word = dictionary.sample.chomp.downcase
    @blank_char = '_ '
    puts @word
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

  def blank_word
    @word.split('').map { |char| char.replace @blank_char }
  end

  def solved?(feedback)
    true if @word.split('') == feedback
  end
end

# Responsible for executing the actions of the player, namely guessing
class Player
  def guess
    puts 'Enter guess now'
    this_guess = gets.chomp.downcase
    this_guess
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
  end

  def play
    puts 'Load previous game? y/n'
    load_game if gets.chomp == 'y'
    puts 'Save and quit the game any round by entering "save" in place of your guess'
    print_feedback(@previous_feedback)
    game_loop
    @secret.solved?(@previous_feedback) ? puts('You won!') : puts('You lose you big looser!')
  end

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
    File.open('hangman_save.yaml', 'w') { |file| file.write(current_state.to_yaml) }
    puts 'Game saved. You can now quit by hitting control + c.'
  end

  def current_state
    {
      secret: @secret,
      gallows: @gallows,
      previous_feedback: @previous_feedback,
      incorrect_guesses: @incorrect_guesses
    }
  end

  def load_game
    save = YAML.load_file('hangman_save.yaml')
    @secret = save[:secret]
    @gallows = save[:gallows]
    @previous_feedback = save[:previous_feedback]
    @incorrect_guesses = save[:incorrect_guesses]
  end
end

game = Game.new
game.play
