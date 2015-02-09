class CardsBuilder
  def initialize(cards_string)
    @cards_string = cards_string
  end

  def cards
    @cards = @cards_string.split(' ').map do |card_string|
      CardBuilder.new(card_string).card
    end

    card_names = @cards.map(&:to_s_with_suit)
    raise ArgumentError if card_names.uniq != card_names

    puts "cards: #{@cards.map(&:to_s)}"

    @cards
  end
end

class CardBuilder
  def initialize(card_string)
    @suit_string = card_string.slice! -1
    @card_string = card_string
  end

  def card
    suit = Suit.new(@suit_string).suit
    Card.new @card_string, suit
  end
end

class Card
  VALID_RANKS = [ "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A" ]

  attr_reader :card_string, :suit

  def initialize(card_string, suit)
    raise ArgumentError unless VALID_RANKS.include? card_string

    @card_string = card_string
    @suit = suit
  end

  def to_s
    card_string
  end

  def to_s_with_suit
    "#{card_string} (#{suit})"
  end

  def <=>(other_card)
    VALID_RANKS.index(card_string) <=> VALID_RANKS.index(other_card.card_string)
  end

  def ==(other_card)
    card_string == other_card.card_string if other_card
  end
end

class Suit
  VALID_SUITS = [ "H", "D", "C", "S" ]

  attr_reader :suit

  def initialize(suit)
    raise ArgumentError unless VALID_SUITS.include? suit
    @suit = suit
  end

  def to_s
    self.class.name
  end
end

class StraightMatcher
  def matches?(cards)
    @straight ||= begin
      sorted = @cards.sort

      if check_straight(sorted[2..6])
        sorted[2..6]
      elsif check_straight(sorted[1..5])
        sorted[1..5]
      elsif check_straight(sorted[0..4])
        sorted[0..4]
      end
    end
  end

  def straight
    @straight
  end
end

class FlushMatcher
  def matches?(cards)
    cards_by_suit.keys.each do |suit|
      if cards_by_suit[suit].count >= 5
        return cards_by_suit[suit].sort.reverse.first
      end
    end

    false
  end
end

class StraightFlushMatcher
  def initialize()
    @straight_matcher = StraightMatcher.new
    @flush_matcher = FlushMatcher.new
  end

  def matches?(cards)
    if straight? && flush? && straight.map { |x| x.suit}.uniq.length == 1
      flush?
    end
  end
end

class RoyalFlushMatcher
  def initialize
    @straight_flush_matcher = StraightFlushMatcher.new
  end

  def matches?(cards)
    @straight_flush_matcher.matches?(cards)

    if straight? && flush? && straight? == flush? && straight?.card_string == 'A'
      straight?
    end
  end
end

class Hand
end

class HighCard < Hand
  def initialize(card)
    @card = card
  end

  def to_s
    "High Card (#{@card} high)"
  end
end

class Hands
  def initialize(cards)
    @cards = cards
  end

  def best_hand
    hands = []

    #hands << RoyalFlush.new(self) if royal_flush?
    #hands << StraightFlush.new(self) if straight_flush?
    #hands << FourOfAKind.new(self) if four_of_a_kind?

    #hands.sort.first

    #hands = [
      #RoyalFlush.new(cards),
      #StraightFlush.new(cards),
      #FourOfAKind.new(cards),
      #FullHouse.new(cards),
      #Straight.new(cards),
      #ThreeOfAKind.new(cards),
      #TwoPair.new(cards),
      #TwoOfAKind.new(cards)
    #].compact.sort.first

    if kind = royal_flush?
      "Royal Flush (#{kind} high)"
    elsif kind = straight_flush?
      "Straight Flush (#{kind} high)"
    elsif kind = four_of_a_kind?
      "Four of a Kind (#{kind} high)"
    elsif kind = full_house?
      "Full House (#{kind} high)"
    elsif kind = flush?
      "Flush (#{kind} high)"
    elsif kind = straight?
      "Straight (#{kind} high)"
    elsif kind = three_of_a_kind?
      "Three of a Kind (#{kind} high)"
    elsif pair = two_pair?
      "Two Pair (#{pair.first.first.card_string} high)"
    elsif kind = two_of_a_kind?
      "Two of a Kind (#{kind} high)"
    else
      HighCard.new(@cards.sort.last).to_s
    end
  end

  def high_card
    @cards.sort.last
  end

  def full_house?
    two_of_a_kind? && three_of_a_kind?
  end

  def two_pair?
    pairs if pairs.count >= 2
  end

  def straight_flush?
  end

  def royal_flush?
    if straight? && flush? && straight? == flush? && straight?.card_string == 'A'
      straight?
    end
  end

  def straight
    @straight ||= begin
      sorted = @cards.sort

      if check_straight(sorted[2..6])
        sorted[2..6]
      elsif check_straight(sorted[1..5])
        sorted[1..5]
      elsif check_straight(sorted[0..4])
        sorted[0..4]
      end
    end
  end

  def straight?
    straight.last if straight
  end

  def flush?
    cards_by_suit.keys.each do |suit|
      if cards_by_suit[suit].count >= 5
        return cards_by_suit[suit].sort.reverse.first
      end
    end

    false
  end

  def check_straight(five_cards)
    index = Card::VALID_RANKS.index(five_cards.first.to_s)

    if index + 4 > Card::VALID_RANKS.length
      return false
    end

    things = Card::VALID_RANKS[index..(index+4)]

    five_cards = five_cards.map(&:to_s)
    five_cards == things
  end

  def pairs
    return @pairs if @pairs

    @pairs = []

    kinds.keys.each do |kind|
      @pairs << kinds[kind] if kinds[kind].count >= 2
    end

    @pairs
  end

  def two_of_a_kind?
    kinds.keys.each do |kind|
      if kinds[kind].count == 2
        return kind
      end
    end

    false
  end

  def three_of_a_kind?
    kinds.keys.each do |kind|
      if kinds[kind].count == 3
        return kind
      end
    end

    false
  end

  def four_of_a_kind?
    kinds.keys.each do |kind|
      if kinds[kind].count == 4
        return kind
      end
    end

    false
  end

  def kinds
    return @kinds if @kinds

    @kinds = {}

    @cards.sort.reverse.each do |card|
      @kinds[card.card_string] ||= []
      @kinds[card.card_string] << card
    end

    @kinds
  end

  def cards_by_suit
    return @cards_by_suit if @cards_by_suit

    @cards_by_suit = {}

    @cards.sort.reverse.each do |card|
      @cards_by_suit[card.suit] ||= []
      @cards_by_suit[card.suit] << card
    end

    @cards_by_suit
  end
end

class TexasHoldEm
  def initialize(cards)
    @cards = CardsBuilder.new(cards).cards
    raise ArgumentError.new unless @cards.count == 7
    @hand = Hands.new(@cards)
  end

  def best_hand
    @hand.best_hand
  end
end
