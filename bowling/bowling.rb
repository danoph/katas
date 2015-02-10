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
    @game = Game.new

    i = 0
    while(i < throws.count) do
      if @frames.count == 10
        @frames << TenthFrame.new(@frame_number, throws[i..-1])
        i = throws.count
      else
        if throws[i] == 'X'
          @frames << StrikeFrame.new(@frame_number)
          i += 1
        else
          @frames << Frame.new(@frame_number, throws[i], throws[i+1])
          i += 2
        end
      end
    end
    if @frames < 10
      raise GameTooShort.new
    end

    if @frames > 10
      raise GameTooLong.new
    end
  end

  def score
    ball_scorer = BallScorer.new(@frames)
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

#class Strike
  #def score
    #10
  #end
#end

#class GutterBall
  #def score
    #0
  #end
#end

#class Frame
  #attr_reader :number, :throws

  #def initialize(number)
    #@number = number
    #@throws = []
    #@score = 0
  #end

  #def add_throw(ball)
    #@throws << ball
  #end

  #def finished?
    #if @number < 10
      #@throws.detect{|t| t.is_a? Strike } || @throws.count == 2
    #else
      #@throws.count == 3
    #end
  #end

  #def score

  #end
#end
class StrikeFrame
  attr_reader :number
  def initialize(number, throws = nil)
    @number = number
  end

  def score(balls)
    10 + balls[0] + balls[1]
  end

  def next_rolls_needed_for_score
    2
  end
end

class SpareFrame
  attr_reader :number
  def initialize(number, throws)
    @number = number
    @first = throws[0]
  end

  def score(balls)
    10 + balls[0]
  end

  def next_rolls_needed_for_score
    1
  end
end

class OpenFrame
  attr_reader :number
  def initialize(number, throws)
    @number = number
    @first = throws[0]
    @second = throws[1]
  end

  def score(balls = [])
    @first + @second
  end

  def next_rolls_needed_for_score
    0
  end
end

class Frame
  def initialize(number, ball_one, ball_two)
    if ball_one == '/'
      raise Bowling::SpareTooEarly.new
    end
  end
end

class TenthFrame
  attr_reader :number
  def initialize(number, throws)
    @number = number
  end
end

