class TexasHoldEmCardValidator
  VALID_RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  VALID_SUITS = %w(D C S H)

  def valid_card?(card)
    VALID_RANKS.include?(card.rank) && VALID_SUITS.include?(card.suit)
  end
end

class Card
  attr_reader :rank, :suit

  def initialize(card_string)
    @card_string = card_string
    @rank = card_string[0...-1]
    @suit = card_string[-1]
  end

  def to_s
    @card_string
  end

  def hash
    @card_string.hash
  end

  def eql?(other_card)
    other_card.rank == rank && other_card.suit == suit
  end
end

class TexasHoldEm
  VALID_NUMBER_OF_CARDS = 7

  def initialize(cards_string)
    card_validator = TexasHoldEmCardValidator.new

    cards = cards_string.split(' ').map do |card_string|
      card = Card.new(card_string)
      raise ArgumentError, "Should not accept #{ card }" unless card_validator.valid_card?(card)
      card
    end

    raise ArgumentError, "Should not accept more than 7 cards" if cards.length > VALID_NUMBER_OF_CARDS
    raise ArgumentError, "Should not accept fewer than 7 cards" if cards.length < VALID_NUMBER_OF_CARDS
    raise ArgumentError, "Should not accept duplicated cards" if cards.length != cards.uniq.length
  end
end
