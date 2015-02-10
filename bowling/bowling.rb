class Bowling

  class GameTooShort  < StandardError; end
  class GameTooLong   < StandardError; end
  class SpareTooEarly < StandardError; end
  class StrikeTooLate < StandardError; end
  class TooManyPins   < StandardError; end

  def initialize(throws)
    @throws = throws.split('')
    play_game
  end

  def play_game
    balls = []

    @throws.each do |bowling_throw|
      case bowling_throw
      when 'X'
        ball = Strike.new
      when '-'
        ball = GutterBall.new
      when '/'
        ball = Spare.new
      else
        ball = NormalBall.new(bowling_throw)
      end

      balls << ball
    end

    @game = Game.new(balls)
    @game.play
  end

  def score
    @game.score
  end
end

class Game
  def initialize(balls, frame_scorer = FrameScorer.new)
    @balls = balls
    @frame_scorer = frame_scorer
    @frame_number = 0
    @score = 0
  end

  def play
    frame = new_frame

    @balls.each do |ball|
      ball.frame = frame

      frame.add_throw(ball)

      if frame.finished?
        @frame_scorer.add_frame(frame)
        frame = new_frame
      end
    end
  end

  def new_frame
    @frame_number += 1

    if @frame_number == 10
      TenthFrame.new
    else
      Frame.new @frame_number
    end
  end

  def score
    @score = @frame_scorer.score

    puts "End Score:"
    puts "\t#{@score}"

    @score
  end
end

class FrameScorer
  attr_reader :score

  def initialize(ball_scorer = BallScorer.new)
    @frames = []
    @score = 0
    @ball_scorer = ball_scorer
  end

  def add_frame(frame)
    @frames << frame
    score_frames
  end

  def score_frames
    @score = 0

    @frames.each do |frame|
      puts "frame: #{frame.number}"

      frame.balls.each_with_index do |ball, index|
        puts "\tball #{index + 1}: #{ball.ball_str} - score: #{ball.score}"
      end

      @score += score_frame frame
    end
  end

  def score_frame(frame)
    frame.score = 0

    frame.balls.each do |ball|
      if ball.is_a? Strike
        puts "scoring strike"
      elsif ball.is_a? Spare
        puts "scoring spare"
      else
        puts "scoring ball: #{ball.ball_str}"
        frame.score += ball.score
        #frame.score += @ball_scorer.ball_score(ball)
      end
    end

    frame.score
  end
end

class BallScorer
  #def initialize(balls)
    #@balls = balls
    #@scores = []
  #end

  #def score_balls
    #@balls.each_with_index do |ball, throw_number|
      #if ball.is_a?(Strike) && ball.frame_number < 10
        #if @balls[throw_number + 1] && @balls[throw_number + 1].closed_frame?
          #ball2 = @balls[throw_number + 1]
          #ball.score += ball2.score
        #end

        #if @balls[throw_number + 2] && @balls[throw_number + 2].closed_frame?
          #ball3 = @balls[throw_number + 2]
          #ball.score += ball3.score
        #end
      #elsif ball.is_a?(Spare)
        #ball.score = 10 - @balls[throw_number - 1].score

        #if @balls[throw_number + 1] && ball.frame_number < 10
          #ball2 = @balls[throw_number + 1]
          #ball.score += ball2.score
        #end
      #end

      #@scores << ball.score

      #puts "ball #{throw_number} - score: #{ball.score}"
    #end

    #@scores.inject(0, &:+)
  #end
end

class Ball
  attr_accessor :frame
  attr_reader :ball_str, :score

  def initialize(ball_str)
    @ball_str = ball_str
    @score = nil
  end

  def frame_number
    frame.number
  end

  def normal?
    false
  end

  def spare?
    false
  end

  def strike?
    false
  end
end

class NormalBall < Ball
  def initialize(ball_str)
    super
    @score = ball_str.to_i
  end

  def normal?
    true
  end
end

class Strike < Ball
  attr_accessor :score

  def initialize
    super 'X'
    @score = 10
  end

  def strike?
    true
  end
end

class Spare < Ball
  attr_accessor :score

  def initialize
    super '/'
  end

  def spare?
    true
  end
end

class GutterBall < Ball
  def initialize
    super '-'
  end

  def score
    0
  end

  def normal?
    true
  end
end

class Frame
  attr_reader :number, :balls
  attr_accessor :open, :score

  def initialize(number)
    @number = number
    @balls = []
    @open = true
    @score = 0
  end

  def add_throw(ball)
    @balls << ball
  end

  def finished?
    @balls.detect{|t| t.is_a?(Strike) || t.is_a?(Spare) } || two_balls?
  end

  def open?
    !!@open
  end

  def close!
    @open = false
  end

  def ball_count
    @balls.count
  end

  def two_balls?
    ball_count == 2
  end

  def first_ball
    @balls[0]
  end

  def second_ball
    @balls[1]
  end
end

class TenthFrame < Frame
  def initialize
    super 10
  end

  def finished?
    two_ball_combos? || three_ball_combos?
  end

  def two_ball_combos?
    ball_ball?
  end

  def ball_ball?
    two_balls? && first_ball.normal? && second_ball.normal?
  end

  def three_ball_combos?
    three_balls? && (ball_spare_ball? || ball_spare_strike? || strike_ball_ball? || strike_ball_spare? || strike_strike_ball? || strike_strike_strike?)
  end

  def ball_spare_ball?
    first_ball.normal? && second_ball.spare? && third_ball.normal?
  end

  def ball_spare_strike?
    first_ball.normal? && second_ball.spare? && third_ball.strike?
  end

  def strike_ball_ball?
    first_ball.strike? && second_ball.normal? && third_ball.normal?
  end

  def strike_ball_spare?
    first_ball.strike? && second_ball.normal? && third_ball.spare?
  end

  def strike_strike_ball?
    first_ball.strike? && second_ball.strike? && third_ball.normal?
  end

  def strike_strike_strike?
    first_ball.strike? && second_ball.strike? && third_ball.strike?
  end

  def third_ball
    @balls[2]
  end

  def three_balls?
    ball_count == 3
  end
end
