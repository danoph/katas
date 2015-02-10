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
    Frame.new @frame_number
  end

  def score
    @frame_scorer.score_frames
  end
end

class FrameScorer
  def initialize
    @frames = []
  end

  def add_frame(frame)
    @frames << frame
  end

  def score_frames
    #ball_scorer = BallScorer.new(@frames.map(&:balls).flatten)
    #@score = ball_scorer.score_balls
    @score = 0

    @frames.each do |frame|
      puts "frame: #{frame.number}"

      frame.balls.each_with_index do |ball, index|
        puts "\tball #{index + 1}: #{ball.ball_str} - score: #{ball.score}"
      end
    end

    puts "End Score:"
    puts "\t#{@score}"

    @score
  end
end

class BallScorer
  def initialize(balls)
    @balls = balls
    @scores = []
  end

  def score_balls
    @balls.each_with_index do |ball, throw_number|
      if ball.is_a?(Strike) && ball.frame_number < 10
        if @balls[throw_number + 1] && @balls[throw_number + 1].closed_frame?
          ball2 = @balls[throw_number + 1]
          ball.score += ball2.score
        end

        if @balls[throw_number + 2] && @balls[throw_number + 2].closed_frame?
          ball3 = @balls[throw_number + 2]
          ball.score += ball3.score
        end
      elsif ball.is_a?(Spare)
        ball.score = 10 - @balls[throw_number - 1].score

        if @balls[throw_number + 1] && ball.frame_number < 10
          ball2 = @balls[throw_number + 1]
          ball.score += ball2.score
        end
      end

      @scores << ball.score

      puts "ball #{throw_number} - score: #{ball.score}"
    end

    @scores.inject(0, &:+)
  end
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

  def closed_frame?
    !frame.open?
  end

  def close_frame!
    frame.close!
  end
end

class NormalBall < Ball
  def initialize(ball_str)
    super
    @score = ball_str.to_i
  end
end

class Strike < Ball
  attr_accessor :score

  def initialize
    super 'X'
    @score = 10
  end
end

class Spare < Ball
  attr_accessor :score

  def initialize
    super '/'
  end
end

class GutterBall < Ball
  def initialize
    super '-'
  end

  def score
    0
  end
end

class Frame
  attr_reader :number, :balls
  attr_accessor :open

  def initialize(number)
    @number = number
    @balls = []
    @open = true
  end

  def add_throw(ball)
    @balls << ball
  end

  def finished?
    if @number < 10
      @balls.detect{|t| t.is_a?(Strike) || t.is_a?(Spare) } || @balls.count == 2
    else
      @balls.count == 3
    end
  end

  def open?
    !!@open
  end

  def close!
    @open = false
  end
end
