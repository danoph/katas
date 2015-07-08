class TexasHoldEm
  def initialize(cards)
    @cards = cards.split ' '

    raise ArgumentError if @cards.length != 7
    raise ArgumentError if @cards != @cards.uniq

    @cards = @cards.map{|c| Card.new(c) }

    @hands = Hands.new(@cards)
  end

  def best_hand
    @hands.best_hand.to_s
  end
end

#1. **Royal Flush** *... this consists of the cards Ace, King, Queen, Jack, and 10 of the same suit.*
#2. **Straight Flush** *... this consists of five cards from the same suit in sequential order.*
#3. **Four of a Kind** *... this consists of the same card in all four suits.*
#4. **Full House** *... this consists of a set of one card in three suits, and a second card in two suits.*
#5. **Flush** *... this consists of five cards of the same suit.*
#6. **Straight** *... this consists of five cards in sequential order.*
#7. **Three of a Kind** *... this consists of the same card in three suits.*
#8. **Two Pair** *... this consists of two distinct pairs of cards.*
#9. **One Pair** *... this consists of the same card in two suits.*
#10. **High Card** *... this is just any single card.*

class Hand
  def initialize(cards)
    @cards = cards
  end

  def <=>(other_hand)
    rank > other_hand.rank ? 1 : -1
  end

  def valid?
    false
  end

  def name
    ""
  end

  def to_s
    "#{name} (#{high_card} high)"
  end
end

class RoyalFlush < Hand
  def rank; 1; end
end

class StraightFlush < Hand
  def rank; 2; end
end

class FourOfAKind < Hand
  def rank; 3; end
end

class FullHouse < Hand
  def rank; 4; end
end

class Flush < Hand
  def rank; 5; end
end

class Straight < Hand
  def rank; 6; end
end

class ThreeOfAKind < Hand
  def rank; 7; end
end

class TwoPair < Hand
  def rank; 8; end
end

class OnePair < Hand
  def rank; 9; end

  def name
    "Two of a Kind"
  end

  def high_card

  end

  def valid?
    true if @cards.map(&:card_string).uniq != @cards.map(&:card_string)
  end
end

class HighCard < Hand
  def rank; 10; end

  def name
    "High Card"
  end

  def high_card
    @cards.sort.reverse.pop
  end

  def valid?
    true
  end
end

POSSIBLE_HANDS = [ RoyalFlush, StraightFlush, FourOfAKind, FullHouse, Flush, Straight, ThreeOfAKind, TwoPair, OnePair, HighCard ]

class Hands
  def initialize(cards)
    @cards = cards
    @hands = POSSIBLE_HANDS.map{|hand| build_hand(hand) }.compact
  end

  def build_hand(possible_hand)
    hand = possible_hand.new(@cards)
    hand if hand.valid?
  end

  def best_hand
    @hands.sort.reverse.pop
  end
end

class Card
  VALID_RANKS = [ "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A" ]
  VALID_SUITS = [ "H", "D", "C", "S" ]

  attr_reader :card_string

  def initialize(card_string)
    @suit = card_string.slice! -1
    @card_string = card_string

    raise ArgumentError unless valid?
  end

  private

  def valid?
    VALID_RANKS.include?(@card_string) && VALID_SUITS.include?(@suit)
  end

  def <=>(other_card)
    if VALID_RANKS.find_index(@card_string) > VALID_RANKS.find_index(other_card.card_string)
      -1
    else
      1
    end
  end

  def to_s
    "#{@card_string}"
  end
end
