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
    suits = []
    @cards.each do |card|
      ranks << card[0...-1]
      suits << card[-1]
    end

    pairs = find_pairs(ranks)
    triplets = find_triplets(ranks)
    quads = find_quads(ranks)
    flush = find_flush(suits)

    if flush.length == 1
      flush_ranks = find_flush_ranks(flush[0])
      straight = find_straight(flush_ranks)
      if straight
        "Straight Flush (#{ straight } high)"
      else
        "Flush (#{ high_value(ranks) } high)"
      end
    else
      straight = find_straight(ranks)
      if straight
        "Straight (#{ straight } high)"
      elsif quads.length == 1
        "Four of a Kind (#{ quads.max } high)"
      elsif triplets.length == 1
        full_house_pairs = find_pairs(ranks-triplets)
        if full_house_pairs.length >= 1
          "Full House (#{ triplets.max } high)"
        else
          "Three of a Kind (#{ triplets.max } high)"
        end
      else
        if pairs.length == 1
          "Two of a Kind (#{ pairs[0] } high)"
        elsif pairs.length == 2
          "Two Pair (#{ pairs.max } high)"
        else
          "High Card (#{ high_value(ranks) } high)"
        end
      end
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

  def high_value(ranks)
    # create array of index locations of each ranks within the @ranks list
    rank1 = ranks.map{|e| @ranks.find_index(e) }
    puts "ranks 1: #{ rank1 }"
    puts "Max: #{ rank1.max }-#{ @ranks[rank1.max] }"
    @ranks[rank1.max]
  end

  def find_pairs(ranks)
    ranks.select{|rank| ranks.count(rank) == 2 }.uniq
  end

  def find_triplets(ranks)
    ranks.select{|rank| ranks.count(rank) == 3 }.uniq
  end

  def find_quads(ranks)
    ranks.select{|rank| ranks.count(rank) == 4 }.uniq
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
end
