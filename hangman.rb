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


