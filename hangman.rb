# frozen_string_literal: true

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
    puts @word
  end

  def reveal
    @word
  end

  def matches(guess)
    matching_chars = @word.split('').select { |char| char == guess }
    puts "#{matching_chars.size} letters matching"
    matching_chars.size
  end

  def solved?(right_guesses)
    true if @word.size == right_guesses
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
