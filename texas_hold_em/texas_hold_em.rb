require './card'
require './texas_hold_em_card_validator'

class TexasHoldEmCardsValidator
  VALID_NUMBER_OF_CARDS = 7

  def initialize
    @card_validator = TexasHoldEmCardValidator.new
  end

  def validate(cards)
    raise ArgumentError, "Should not accept more than 7 cards" if cards.length > VALID_NUMBER_OF_CARDS
    raise ArgumentError, "Should not accept fewer than 7 cards" if cards.length < VALID_NUMBER_OF_CARDS
    raise ArgumentError, "Should not accept duplicated cards" if cards.length != cards.uniq.length

    cards.each do |card|
      raise ArgumentError, "Should not accept #{ card }" unless @card_validator.valid_card?(card)
    end
  end
end

class HandsFinder
  def initialize(cards)
    @cards = cards
  end
end

class TexasPlayerCardsFactory
  def build(cards_string)
    cards_string.split(' ').map {|card_string| Card.new(card_string) }
  end
end

class TexasHoldEm
  VALID_NUMBER_OF_CARDS = 7

  def initialize(cards_string)
    cards_factory = TexasPlayerCardsFactory.new
    cards_validator = TexasHoldEmCardsValidator.new

    @cards = cards_factory.build(cards_string)
    cards_validator.validate(@cards)
  end

  def best_hand
    hands_finder = HandsFinder.new(@cards)

    best_hand = hands_finder.all_hands[0]

    "#{best_hand.description} (#{best_hand.high_card} high)"
  end
end
