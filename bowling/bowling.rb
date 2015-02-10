class Bowling

  class GameTooShort  < StandardError; end
  class GameTooLong   < StandardError; end
  class SpareTooEarly < StandardError; end
  class StrikeTooLate < StandardError; end
  class TooManyPins   < StandardError; end

  def initialize(throws)
    @frame_number = 1
    @frames = []
    throws = throws.split('')

    @balls = []

    frame = Frame.new(@frame_number)

    throws.each do |bowling_throw|
      case bowling_throw
      when 'X'
        ball = Strike.new
        frame.open = true
      when '-'
        ball = GutterBall.new
      when '/'
        ball = Spare.new
        frame.open = true
      else
        ball = NormalBall.new(bowling_throw)
      end

      @balls << ball

      ball.frame = frame

      frame.add_throw(ball)

      if frame.finished?
        @frames << frame
        @frame_number += 1

        frame = Frame.new @frame_number
      end
    end
  end

  def score
    ball_scorer = BallScorer.new(@balls)
    @score = ball_scorer.score_balls

    @frames.each do |frame|
      puts "frame: #{frame.number}"

      frame.balls.each do |ball|
        puts "\tball: #{ball} - score: #{ball.score}"
      end
    end

    puts "End Score:"
    puts "\t#{@score}"

    @score

    #@balls.each do |ball|
      #puts "ball: #{ball} - score: #{ball.score}"
    #end
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

      puts "any open frames: #{any_open_frames?}"

      puts "ball #{throw_number} - score: #{ball.score}"
    end

    @scores.inject(0, &:+)
  end

  def any_open_frames?
    @balls.detect{|ball| !ball.closed_frame? }
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

  def close_frame
    frame.close
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
    @open = false
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

  def close
    @open = false
  end
end
