class TexasHoldEmCardValidator
  VALID_RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  VALID_SUITS = %w(D C S H)

  def valid_card?(card)
    VALID_RANKS.include?(card.rank) && VALID_SUITS.include?(card.suit)
  end
end

