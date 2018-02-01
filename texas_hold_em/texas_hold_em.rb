class TexasHoldEm
  VALID_RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  VALID_SUITS = %w(D C S H)

  def initialize(card_string)
    cards = card_string.split ' '

    cards.each do |card|
      rank = card[0...-1]
      suit = card[-1]

      raise ArgumentError, "Should not accept #{ card }" unless VALID_RANKS.include?(rank) && VALID_SUITS.include?(suit)
    end
  end
end
