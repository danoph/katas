require 'minitest/autorun'
require './texas_hold_em'

class TexasHoldEmTest < Minitest::Test

  ##############
  #            #
  # Validation #
  #            #
  ##############

  BAD_CARDS = %w( 1H 2J )

  def test_invalid_card
    BAD_CARDS.each do |bad_card|
      assert_raises(ArgumentError, "Should not accept #{ bad_card }") do
        TexasHoldEm.new("2C 3C 4C 5C 6C 7C #{ bad_card }")
      end
    end
  end

  def test_too_many_cards
    assert_raises(ArgumentError, "Should not accept more than 7 cards") do
      TexasHoldEm.new("KD 9H 10D AD JD 6S QD 6D")
    end
  end

  def test_too_few_cards
    assert_raises(ArgumentError, "Should not accept fewer than 7 cards") do
      TexasHoldEm.new("KD 9H 10D AD JD 6S")
    end
  end

  def test_duplicate_cards
    assert_raises(ArgumentError, "Should not accept duplicated cards") do
      TexasHoldEm.new("KD 9H 10D AD JD 6S 9H")
    end
  end

  ###############
  #             #
  # Royal Flush #
  #             #
  ###############

  def test_royal_flush
    cards = "KD 9H 10D AD JD 6S QD"
    assert_equal "Royal Flush (A high)", TexasHoldEm.new(cards).best_hand
  end

  ##################
  #                #
  # Straight Flush #
  #                #
  ##################

  def test_straight_flush
    cards = "KD 9H 10D 9D JD 6S QD"
    assert_equal "Straight Flush (K high)", TexasHoldEm.new(cards).best_hand
  end

  ##################
  #                #
  # Four of a Kind #
  #                #
  ##################

  def test_pick_four_of_a_kind
    cards = "4C 7D 7H 3S 7C 10H 7S"
    assert_equal "Four of a Kind (7 high)", TexasHoldEm.new(cards).best_hand
  end

  ##############
  #            #
  # Full House #
  #            #
  ##############

  def test_pick_correct_high_card_for_full_house
    cards = "AH AC 2D 2H 2C 5S 8S"
    assert_equal "Full House (2 high)", TexasHoldEm.new(cards).best_hand
  end

  #########
  #       #
  # Flush #
  #       #
  #########

  def test_flush_beats_straight
    cards = "2D 4D 6D 7C 8C 9D 10D"
    assert_equal "Flush (10 high)", TexasHoldEm.new(cards).best_hand, "Flush (10 high), #{cards}"
  end

  ############
  #          #
  # Straight #
  #          #
  ############

  def test_straight
    cards = "2C 4D AH 6S 5D 3C 10S"
    assert_equal "Straight (6 high)", TexasHoldEm.new(cards).best_hand
  end

  ###################
  #                 #
  # Three of a Kind #
  #                 #
  ###################

  def test_pick_three_of_a_kind
    cards = "4C 7D QH 3S 7H 10H 7S"
    assert_equal "Three of a Kind (7 high)", TexasHoldEm.new(cards).best_hand
  end

  ############
  #          #
  # Two Pair #
  #          #
  ############

  def test_pick_two_pair
    cards = "4C 7D QH 3S 7H 10H QS"
    assert_equal "Two Pair (Q high)", TexasHoldEm.new(cards).best_hand, "Two Pair (Q high) - #{cards}"
  end

  #################
  #               #
  # Two of a Kind #
  #               #
  #################

  def test_pick_two_of_a_kind
    cards = "4C 7D 2H 3S JD 10H 7S"
    puts "\ncards: #{cards}\n"
    assert_equal "Two of a Kind (7 high)", TexasHoldEm.new(cards).best_hand, "Two of a Kind (7 high) #{cards}"
  end

  #############
  #           #
  # High Card #
  #           #
  #############

  def test_pick_high_card
    cards = "4C 7D 2H 3S KD 10H 6S"
    assert_equal "High Card (K high)", TexasHoldEm.new(cards).best_hand
  end

end
