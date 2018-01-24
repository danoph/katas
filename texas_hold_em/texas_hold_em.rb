class TexasHoldEm

  def initialize(cards)
    # Implement me!
    cards = cards.split(' ')

    if cards.length > 7
      raise(ArgumentError, 'Should not accept more than 7 cards')
    elsif cards.length < 7
      raise(ArgumentError, 'Should not accept fewer than 7 cards')
    end

    if cards.uniq.length != 7
      raise(ArgumentError, 'Should not accept duplicated cards')
    end

  end

  def best_hand
    # Implement me!
  end

end
