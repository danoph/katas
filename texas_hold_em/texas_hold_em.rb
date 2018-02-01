require './card'
require './texas_hold_em_card_validator'

class TexasHoldEm
  VALID_NUMBER_OF_CARDS = 7

  def initialize(cards_string)
    card_validator = TexasHoldEmCardValidator.new

    cards = cards_string.split(' ').map do |card_string|
      card = Card.new(card_string)
      raise ArgumentError, "Should not accept #{ card }" unless card_validator.valid_card?(card)
      card
    end

    raise ArgumentError, "Should not accept more than 7 cards" if cards.length > VALID_NUMBER_OF_CARDS
    raise ArgumentError, "Should not accept fewer than 7 cards" if cards.length < VALID_NUMBER_OF_CARDS
    raise ArgumentError, "Should not accept duplicated cards" if cards.length != cards.uniq.length
  end

  def best_hand
  end
end
