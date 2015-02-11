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
    @game.output_game
    @game.score
  end
end

class Game
  def initialize(balls)
    @balls = balls
    @frame_scorer = FrameScorer.new(BallScorer.new(balls))
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
    @frame_scorer.score
  end

  def output_game
    running_score = 0

    @frame_scorer.frames.each do |frame|
      running_score += frame.score
      puts "frame: #{frame.number} - score: #{frame.score} - running score: #{running_score}"

      frame.balls.each_with_index do |ball, index|
        puts "\tball #{index + 1}: #{ball.ball_str} - score: #{ball.score}"
      end
    end

    puts "End Score:"
    puts "\t#{score}"
  end
end

class FrameScorer
  attr_reader :score, :frames

  def initialize(ball_scorer)
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
      @score += score_frame frame
    end
  end

  def score_frame(frame)
    frame.score = 0

    frame.balls.each do |ball|
      frame.score += @ball_scorer.score_ball(ball)
    end

    frame.score
  end
end

class BallScorer
  def initialize(balls)
    @balls = balls
  end

  def score_ball(ball)
    if ball.strike?
      score_strike ball
    elsif ball.spare?
      score_spare ball
    else
      score_normal ball
    end
  end

  def score_strike(ball)
    score = ball.score

    unless ball.frame_number == 10
      ball_one = next_ball(ball)

      if ball_one && ball_one.scored?
        score += ball_one.score

        ball_two = next_ball(ball_one)

        if ball_two && ball_two.scored?
          score += ball_two.score
        end
      end
    end

    score
  end

  def score_spare(ball)
    prev_ball = previous_ball(ball)
    ball.score = 10 - prev_ball.score

    score = ball.score

    unless ball.frame_number == 10
      ball_one = next_ball(ball)

      if ball_one && ball_one.scored?
        score += ball_one.score
      end
    end

    score
  end

  def score_normal(ball)
    ball.score
  end

  def previous_ball(ball)
    @balls[@balls.find_index(ball) - 1]
  end

  def next_ball(ball)
    @balls[@balls.find_index(ball) + 1]
  end
end

class Ball
  attr_accessor :frame
  attr_reader :ball_str, :score

  def initialize(ball_str)
    @ball_str = ball_str
    @score = nil
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

  def frame_number
    frame.number
  end

  def scored?
    !!@score
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
    @score = 0
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
    validate_throw!
  end

  def finished?
    @balls.detect{|ball| ball.strike? || ball.spare? } || two_balls?
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

  private

  def validate_throw!
    raise Bowling::StrikeTooLate if strike_too_late?
    raise Bowling::SpareTooEarly if spare_too_early?
    raise Bowling::TooManyPins if too_many_pins?
  end

  def strike_too_late?
    second_ball && second_ball.strike?
  end

  def spare_too_early?
    first_ball && first_ball.spare?
  end

  def too_many_pins?
    two_balls? && first_ball.normal? && second_ball.normal? && first_ball.score + second_ball.score == 10
  end
end

class TenthFrame < Frame
  def initialize
    super 10
  end

  def validate_throw!
    super
    raise Bowling::GameTooLong if three_balls? && !three_ball_combos?
  end

  def strike_too_late?
    false
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
