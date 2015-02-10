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

    @throws = []

    frame = Frame.new(@frame_number)

    throws.each do |bowling_throw|
      case bowling_throw
      when 'X'
        ball = Strike.new
      when '-'
        ball = GutterBall.new
      end

      @throws << ball

      frame.add_throw(ball)

      puts "frame finished?: #{frame.finished?}"

      if frame.finished?
        @frames << frame
        @frame_number += 1

        frame = Frame.new @frame_number
      end
    end
  end

  def score
    ball_scorer = BallScorer.new(@throws)
    @score = ball_scorer.score_balls
  end
end

class BallScorer
  def initialize(throws)
    @throws = throws
    @scores = []
  end

  def score_balls
    @throws.each_with_index do |ball, throw_number|
      score = ball.score

      if @throws[throw_number + 1]
        frame2 = @throws[throw_number + 1]
        score += frame2.score
      end

      if @throws[throw_number + 2]
        frame2 = @throws[throw_number + 2]
        score += frame2.score
      end

      @scores << score

      puts "ball #{throw_number} - score: #{score}"
    end
    puts "|#{@scores}|"

    @scores.inject(0, &:+)
  end
end

class Strike
  def score
    10
  end
end

class GutterBall
  def score
    0
  end
end

class Frame
  attr_reader :number, :throws

  def initialize(number)
    @number = number
    @throws = []
    @score = 0
  end

  def add_throw(ball)
    @throws << ball
  end

  def finished?
    if @number < 10
      @throws.detect{|t| t.is_a? Strike } || @throws.count == 2
    else
      @throws.count == 3
    end
  end

  def score

  end
end
