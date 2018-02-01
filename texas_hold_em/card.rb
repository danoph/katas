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
