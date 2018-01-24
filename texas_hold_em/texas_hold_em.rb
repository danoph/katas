class TexasHoldEm

  def validate_cards(cards)

    valid_values = ['A','2','3','4','5','6','7','8','9','10','J','Q','K']

    valid_suits = ['H','C','S','D']

    valid_cards = valid_suits.map do |suit|
      valid_values.map{|value| "#{ value }#{ suit }" }
    end.flatten

    cards.each do |card|
      unless valid_cards.find{|valid_card| card == valid_card }
        raise ArgumentError, "Should not accept #{ card }"
      end
    end

  end

  def initialize(cards)
    cards = cards.split(' ')

    if cards.length > 7
      raise(ArgumentError, 'Should not accept more than 7 cards')
    elsif cards.length < 7
      raise(ArgumentError, 'Should not accept fewer than 7 cards')
    end

    if cards.uniq.length != 7
      raise(ArgumentError, 'Should not accept duplicated cards')
    end

    validate_cards(cards)
  end

  def best_hand
    # Implement me!
  end

end
