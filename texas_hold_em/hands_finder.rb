class TwoOfAKind
  def initialize(cards)
    @cards = cards
  end

  def description
    'Two of a Kind'
  end

  def high_card
    @cards.sort[-1]
  end
end

class HandsFinder
  def initialize(cards)
    @cards = cards
  end

  def all_hands
    two_of_a_kind_hands = []

    used_cards = []

    @cards.each do |card|
      @cards.each do |card2|
        if card.rank == card2.rank && card != card2 && !used_cards.include?(card) && !used_cards.include?(card2)
          two_of_a_kind_hands << TwoOfAKind.new([ card, card2 ])
          used_cards << card
          used_cards << card2
        end
      end
    end

    two_of_a_kind_hands
  end
end
