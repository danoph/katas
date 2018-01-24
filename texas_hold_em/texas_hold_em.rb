class TexasHoldEm
  def initialize(cards)
    @cards = cards.split(' ')

    if @cards.length > 7
      raise(ArgumentError, 'Should not accept more than 7 cards')
    elsif @cards.length < 7
      raise(ArgumentError, 'Should not accept fewer than 7 cards')
    end

    if @cards.uniq.length != 7
      raise(ArgumentError, 'Should not accept duplicated cards')
    end

    validate_cards
  end

  def best_hand
    # @cards.each do |card|
    #
    # end

    "High Card (K high)"
  end

  private

  def validate_cards
    ranks = ['A','2','3','4','5','6','7','8','9','10','J','Q','K']

    suits = ['H','C','S','D']

    valid_cards = suits.map do |suit|
      ranks.map{|rank| "#{ rank }#{ suit }" }
    end.flatten

    @cards.each do |card|
      unless valid_cards.find{|valid_card| card == valid_card }
        raise ArgumentError, "Should not accept #{ card }"
      end
    end
  end

end
