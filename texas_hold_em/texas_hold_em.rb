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
  end

  def best_hand
    ranks = []
    suits = []
    @cards.each do |card|
      ranks << get_rank(card)
      suits << get_suit(card)
    end

    pairs = find_pairs(ranks)
    triplets = find_triplets
    quads = find_quads
    flush = find_flush(suits)
    straight = find_straight(ranks)

    if flush.length == 1
      flush_ranks = find_flush_ranks(flush[0])
      straight_flush = find_straight(flush_ranks)

      if straight_flush
        if straight_flush == 'A'
          "Royal Flush (#{ straight_flush } high)"
        else
          "Straight Flush (#{ straight_flush } high)"
        end
      else
        "Flush (#{ high_value(flush_ranks) } high)"
      end
    else
      if straight
        "Straight (#{ straight } high)"
      elsif quads.length == 4
        high_card_rank = get_high_card_rank(quads)

        "Four of a Kind (#{ high_card_rank } high)"
      elsif triplets.length >= 1
        high_card_rank = get_high_card_rank(triplets)

        full_house_pairs = find_pairs(ranks - [high_card_rank])

        if full_house_pairs.length >= 1
          "Full House (#{ high_card_rank } high)"
        else
          "Three of a Kind (#{ high_card_rank } high)"
        end
      else
        if pairs.length == 1
          "Two of a Kind (#{ pairs[0] } high)"
        elsif pairs.length == 2
          "Two Pair (#{ pairs.max } high)"
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

  def find_pairs(ranks)
    ranks.select{|rank| ranks.count(rank) >= 2 }.uniq
  end

  def find_triplets
    @cards.select{|card| @card_ranks.count(get_rank(card)) == 3 }
  end

  def find_quads
    @cards.select{|card| @card_ranks.count(get_rank(card)) == 4 }
  end

  def find_flush(suits)
    suits.select{|suit| suits.count(suit) >= 5 }.uniq
  end

  def find_flush_ranks(suit)
    ranks = []
    filtered_cards = @cards.select{|card| card[-1] == suit}
    filtered_cards.each do |card|
      ranks << card[0...-1]
    end
    ranks
  end

  def find_straight(ranks)
    previous_rank = nil
    straight_rank = []
    ordered_ranks = ranks.map{|e| @ranks.find_index(e) }.sort
    ordered_ranks.each do |rank|
      if !previous_rank
        straight_rank << rank
      else
        if previous_rank + 1 == rank
          straight_rank << rank
        else
          if straight_rank.length < 5
            straight_rank = []
          end
        end
      end
      previous_rank = rank
    end

    if straight_rank.length >= 5
      straight_rank[-5]
      @ranks[straight_rank.max]
    else
      nil
    end
  end

  def get_rank(card)
    card[0...-1]
  end

  def get_suit(card)
    card[-1]
  end

end
