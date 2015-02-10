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

    i = 0
    while(i < throws.count) do
      if @frames.count == 9
        frame = TenthFrame.new(@frame_number, throws[i..-1])
        i = throws.count
      else
        if throws[i] == 'X'
          frame = StrikeFrame.new(@frame_number)
          i += 1
        else
          frame = Frame.create(@frame_number, throws[i], throws[i+1])
          if frame.next_rolls_needed_for_score > 0
            frame.next_rolls = throws[(i+1)..(i+frame.next_rolls_needed_for_score)]
          end
          i += 2
        end
      end
      if frame.next_rolls_needed_for_score > 0
        frame.next_rolls = throws[(i)..(i+(frame.next_rolls_needed_for_score - 1))]
      end

      @frames << frame
    end
    if @frames.count < 10
      raise GameTooShort.new
    end

    if @frames.count > 10
      raise GameTooLong.new
    end
  end

  def score
    ball_scorer = BallScorer.new(@frames)
    @score = ball_scorer.score_balls
  end
end

class BallScorer
  def initialize(frames)
    @frames = frames
  end

  def score_balls
    score = 0
    @frames.each do |frame|
      score += frame.score
    end
    score
  end
end

class StrikeFrame
  attr_reader :number, :next_rolls
  def initialize(number, throws = nil)
    @number = number
  end

  def score
    if next_rolls[0] == 'X' && next_rolls[1] == 'X'
      30
    else
      if next_rolls[1] == '/'
        20
      else
        if next_rolls[0] == 'X'
          next_rolls[0] = 10
        elsif next_rolls[0] == '-'
          next_rolls[0] = 0
        else
          next_rolls[0] = next_rolls[0].to_i
        end

        if next_rolls[1] == '-'
          next_rolls[1] = 0
        else
          next_rolls[1] = next_rolls[1].to_i
        end
        10 + next_rolls[0] + next_rolls[1]
      end
    end
  end

  def next_rolls=(next_rolls)
    @next_rolls = next_rolls
  end

  def next_rolls_needed_for_score
    2
  end
end

class SpareFrame
  attr_reader :number, :next_rolls
  def initialize(number, throws)
    @number = number
    @first = throws[0]
  end

  def score
    if next_rolls[0] == 'X'
      20
    elsif next_rolls[0] == '-'
      10
    else
      10 + next_rolls[0].to_i
    end
  end

  def next_rolls=(next_rolls)
    @next_rolls = next_rolls
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
    if (@first + @second) >= 10
      raise Bowling::TooManyPins.new
    end
  end

  def score(balls = [])
    @first + @second
  end

  def next_rolls=(next_rolls = nil)
    @next_rolls = next_rolls
  end

  def next_rolls_needed_for_score
    0
  end
end

class Frame
  def self.create(number, ball_one, ball_two)
    if ball_one == '/'
      raise Bowling::SpareTooEarly.new
    end
    if ball_two == 'X'
      raise Bowling::StrikeTooLate.new
    end
    if ball_one == '-'
      ball_one = 0
    else
      ball_one = ball_one.to_i
    end

    if ball_two == '/'
      return SpareFrame.new(number, [ball_one])
    else
      ball_two = ball_two.to_i
      return OpenFrame.new(number, [ball_one, ball_two])
    end
  end
end

class TenthFrame
  attr_reader :number
  def initialize(number, throws)
    @number = number
    @first = throws[0]
    @second = throws[1]
    @third = throws[2]

    if @first == '/'
      raise Bowling::SpareTooEarly.new
    elsif @first == 'X'
      @first = 10
      if (@second.nil? || @third.nil?)
        raise Bowling::GameTooShort.new
      elsif @second == '/'
        raise Bowling::SpareTooEarly.new
      elsif @second == 'X'
        @second = 10
        if @third == 'X'
          @third = 10
        elsif @third == '/'
          raise Bowling::SpareTooEarly.new
        elsif @third == '-'
          @third = 0
        else
          @third = @third.to_i
        end
      else
        if @third == 'X'
          raise Bowling::StrikeTooLate.new
        end
        if @second == '-'
          @second = 0
        else
          @second = @second.to_i
        end

        if @third == '-'
          @third = 0
        end

        if @third == '/'
          @third = 10 - @second
        else
          @third = @third.to_i
          if (@second + @third) > 10
            raise Bowling::TooManyPins.new
          end
        end
      end
    else
      if @second == 'X'
        raise Bowling::StrikeTooLate.new
      end
      if @first == '-'
        @first = 0
      else
        @first = @first.to_i
      end
      if @second == '/'
        @second = 10 - @first
        if @third == 'X'
          @third = 10
        elsif @third == '/'
          raise Bowling::SpareTooEarly.new
        else
          if @third == '-'
            @third = 0
          else
            @third = @third.to_i
          end
        end
      else
        unless @third.nil?
          raise Bowling::GameTooLong.new
        end
        if @second == '-'
          @second = 0
        else
          @second = @second.to_i
        end
        if (@first + @second) > 10
          raise Bowling::TooManyPins.new
        end
      end
    end

  end

  def score
    @first + @second + (@third || 0)
  end

  def next_rolls=(next_rolls = nil)
    @next_rolls = next_rolls
  end

  def next_rolls_needed_for_score
    0
  end
end

