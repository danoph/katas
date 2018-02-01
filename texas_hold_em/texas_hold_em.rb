class Card
  attr_reader :rank, :suit

  def initialize(card_string)
    @rank = card_string[0...-1]
    @suit = card_string[-1]
  end
end

class TexasHoldEm
  VALID_RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  VALID_SUITS = %w(D C S H)

  VALID_NUMBER_OF_CARDS = 7

  def initialize(card_string)
    cards = card_string.split ' '

    cards.each do |card|
      rank = card[0...-1]
      suit = card[-1]

      raise ArgumentError, "Should not accept #{ card }" unless VALID_RANKS.include?(rank) && VALID_SUITS.include?(suit)
    end

    raise ArgumentError, "Should not accept more than 7 cards" if cards.length > VALID_NUMBER_OF_CARDS
    raise ArgumentError, "Should not accept fewer than 7 cards" if cards.length < VALID_NUMBER_OF_CARDS
    raise ArgumentError, "Should not accept duplicated cards" if cards.length != cards.uniq.length
  end
end
