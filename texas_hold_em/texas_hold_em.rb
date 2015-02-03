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

class Hand
  def initialize(cards)
    @cards = cards
  end

  def best_hand
    if kind = four_of_a_kind?
      "Four of a Kind (#{kind} high)"
    elsif kind = three_of_a_kind?
      "Three of a Kind (#{kind} high)"
    elsif pair = two_pair?
      "Two Pair (#{pair} high)"
    elsif kind = two_of_a_kind?
      "Two of a Kind (#{kind} high)"
    else
      "High Card (#{high_card} high)"
    end
  end

  def high_card
    @cards.sort.last
  end

  def two_pair?
    kinds = {}

    @cards.sort.reverse.each do |card|
      kinds[card.card_string] ||= []
      kinds[card.card_string] << card

      if kinds[card.card_string].count == 2
        return card.card_string
      end
    end

    false
  end

  def two_of_a_kind?
    kinds = {}

    @cards.each do |card|
      kinds[card.card_string] ||= []
      kinds[card.card_string] << card
    end

    kinds.keys.each do |kind|
      if kinds[kind].count == 2
        return kind
      end
    end

    false
  end

  def three_of_a_kind?
    kinds = {}

    @cards.each do |card|
      kinds[card.card_string] ||= []
      kinds[card.card_string] << card
    end

    kinds.keys.each do |kind|
      if kinds[kind].count == 3
        return kind
      end
    end

    false
  end

  def four_of_a_kind?
    kinds = {}

    @cards.each do |card|
      kinds[card.card_string] ||= []
      kinds[card.card_string] << card
    end

    kinds.keys.each do |kind|
      if kinds[kind].count == 4
        return kind
      end
    end

    false
  end
end

class TexasHoldEm
  def initialize(cards)
    @cards = CardsBuilder.new(cards).cards
    raise ArgumentError.new unless @cards.count == 7
    @hand = Hand.new(@cards)
  end

  def best_hand
    @hand.best_hand
  end
end
