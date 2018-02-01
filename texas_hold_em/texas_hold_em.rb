class CardValidator
  def initialize(cards)
    @cards = cards
    @ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
    @suits = ['H','C','S','D']
  end

  def validate
    if @cards.length > 7
      raise(ArgumentError, 'Should not accept more than 7 cards')
    elsif @cards.length < 7
      raise(ArgumentError, 'Should not accept fewer than 7 cards')
    end

    if @cards.uniq.length != 7
      raise(ArgumentError, 'Should not accept duplicated cards')
    end

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

class TexasHoldEm
  def initialize(cards)
    @cards = cards.split(' ')
    @ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
    @suits = ['H','C','S','D']

    card_validator = CardValidator.new(@cards)
    card_validator.validate

    @card_ranks = @cards.map{|card| get_rank(card) }
    @card_suits = @cards.map{|card| get_suit(card) }
  end

  def best_hand
    ranks = []
    suits = []
    @cards.each do |card|
      ranks << get_rank(card)
      suits << get_suit(card)
    end

    pairs = find_pairs
    triplets = find_triplets
    quads = find_quads
    flush = find_flush
    straight = find_straight

    if flush.length >= 1
      # flush_ranks = flush.map{|card| get_rank(card) }
      straight_flush = find_straight_from_cards(flush)

      if straight_flush.length >= 1
        high_card_rank = get_high_card_rank(straight_flush)
        if high_card_rank == 'A'
          "Royal Flush (#{ high_card_rank } high)"
        else
          "Straight Flush (#{ high_card_rank } high)"
        end
      else
        "Flush (#{ get_high_card_rank(flush) } high)"
      end
    else
      if straight.length >= 1
        "Straight (#{ get_high_card_rank(straight) } high)"
      elsif quads.length == 4
        high_card_rank = get_high_card_rank(quads)

        "Four of a Kind (#{ high_card_rank } high)"
      elsif triplets.length >= 1
        high_card_rank = get_high_card_rank(triplets)
        cards_without_high_triplets = @cards.reject{|card| get_rank(card) == high_card_rank }
        full_house_pairs = find_pairs_from_cards(cards_without_high_triplets)

        if full_house_pairs.length >= 2
          "Full House (#{ high_card_rank } high)"
        else
          "Three of a Kind (#{ high_card_rank } high)"
        end
      else
        if pairs.length == 2
          "Two of a Kind (#{ get_high_card_rank(pairs) } high)"
        elsif pairs.length >= 4
          "Two Pair (#{ get_high_card_rank(pairs) } high)"
        else
          "High Card (#{ get_high_card_rank(@cards) } high)"
        end
      end
    end
  end

  private

  def get_high_card_rank(cards)
    get_rank(get_high_card(cards))
  end

  def get_high_card(cards)
    cards.sort{|card1, card2| @ranks.find_index(get_rank(card1)) <=> @ranks.find_index(get_rank(card2)) }[-1]
  end

  def high_value(ranks)
    # create array of index locations of each ranks within the @ranks list
    rank1 = ranks.map{|e| @ranks.find_index(e) }
    @ranks[rank1.max]
  end

  def find_pairs
    find_pairs_from_cards(@cards)
  end

  def find_pairs_from_cards(cards)
    cards.select{|card|  @card_ranks.count(get_rank(card)) >= 2 }
  end

  def find_triplets
    @cards.select{|card| @card_ranks.count(get_rank(card)) == 3 }
  end

  def find_quads
    @cards.select{|card| @card_ranks.count(get_rank(card)) == 4 }
  end

  def find_flush
    @cards.select{|card| @card_suits.count(get_suit(card)) >= 5 }
  end

  def find_straight
    find_straight_from_cards(@cards)
  end

  def find_straight_from_cards(cards)
    previous_rank = nil
    straight_rank_indexes = []
    card_ranks = cards.map{|card| get_rank(card) }
    ordered_rank_indexes = card_ranks.map{|e| @ranks.find_index(e) }.sort
    ordered_rank_indexes.each do |rank_index|
      if !previous_rank
        straight_rank_indexes << rank_index
      else
        if previous_rank + 1 == rank_index
          straight_rank_indexes << rank_index
        else
          if straight_rank_indexes.length < 5
            straight_rank_indexes = []
          end
        end
      end
      previous_rank = rank_index
    end

    if straight_rank_indexes.length >= 5
      cards.select do |card|
        card_index = @ranks.find_index(get_rank(card))
        straight_rank_indexes.include?(card_index)
      end
    else
      []
    end
  end

  def get_rank(card)
    card[0...-1]
  end

  def get_suit(card)
    card[-1]
  end

end
