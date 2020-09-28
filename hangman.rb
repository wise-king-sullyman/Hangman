# frozen_string_literal: true

# Responsible for drawing the different stages of the hangmans gallows
class Gallows
  def initialize
    @hangman_stages = File.readlines "hangman_stages.txt"
    @stage = 0
  end

  def draw
    @stage *= 7
    puts @hangman_stages.slice(@stage..@stage + 6)
  end

  def next
    @stage += 1
  end
end
