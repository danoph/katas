class TexasHoldEm
  def initialize(cards)
    @cards = cards.split(' ')
    @ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
    @suits = ['H','C','S','D']

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
    ranks = []
    @cards.each do |card|
      ranks << card[0...-1]
    end

    if ranks.uniq.length == 6
      "Two of a Kind (7 high)"
    else
      "High Card (K high)"
    end
  end

  private

  def validate_cards

    valid_cards = @suits.map do |suit|
      @ranks.map{|rank| "#{ rank }#{ suit }" }
    end.flatten

    @cards.each do |card|
      unless valid_cards.find{|valid_card| card == valid_card }
        raise ArgumentError, "Should not accept #{ card }"
      end
    end
  end

end
