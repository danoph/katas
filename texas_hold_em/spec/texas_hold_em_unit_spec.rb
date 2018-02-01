require 'test/unit'
require_relative '../texas_hold_em'

#describe TexasHoldEmPlayerCardsBuilder do
  #subject { described_class.new }

  #describe '#build' do
    #let(:card_string1) { '2C' }
    #let(:card_string2) { 'JD' }
    #let(:cards_string) { [ card_string1, card_string2 ].join(' ') }

    #let(:cards) { [ two_of_clubs, jack_of_diamonds ] } let(:two_of_clubs) { double 'two of clubs' }
    #let(:jack_of_diamonds) { double 'jack of diamonds' }

    #it 'returns a bunch of cards' do
      #expect(Card).to receive(:new).with(card_string1) { two_of_clubs }
      #expect(Card).to receive(:new).with(card_string2) { jack_of_diamonds }

      #expect(subject.build(cards_string)).to eq(cards)
    #end
  #end
#end

describe TexasHoldEmCardsValidator do
  let(:card1) { double 'card 1' }
  let(:card2) { double 'card 2' }
  let(:card3) { double 'card 3' }
  let(:card4) { double 'card 4' }
  let(:card5) { double 'card 5' }
  let(:card6) { double 'card 6' }
  let(:card7) { double 'card 7' }
  let(:card8) { double 'card 8' }

  describe '#validate' do
    context 'when more than 7 cards passed in' do
      let(:cards) { [ card1, card2, card3, card4, card5, card6, card7, card8 ] }

      it 'raises error' do
        expect { subject.validate(cards) }.to raise_error(ArgumentError, "Should not accept more than 7 cards")
      end
    end

    context 'when less than 7 cards passed in' do
      let(:cards) { [ card1, card2, card3, card4, card5, card6 ] }

      it 'raises error' do
        expect { subject.validate(cards) }.to raise_error(ArgumentError, "Should not accept fewer than 7 cards")
      end
    end

    context 'when duplicate cards passed in' do
      let(:cards) { [ card1, card2, card2, card4, card5, card6, card7 ] }

      it 'raises error' do
        expect { subject.validate(cards) }.to raise_error(ArgumentError, "Should not accept duplicated cards")
      end
    end

    context 'when a bad card is passed in' do
      let(:cards) { [ card1, card2, card3, card4, card5, card6, card7 ] }
      let(:card_validator) { double 'card validator', valid_card?: true }

      before do
        allow(TexasHoldEmCardValidator).to receive(:new) { card_validator }
        allow(card_validator).to receive(:valid_card?).with(card3) { false }
      end

      it 'raises error' do
        expect { subject.validate(cards) }.to raise_error(ArgumentError, "Should not accept #{card3}")
      end
    end
  end
end

describe TexasPlayerCardsFactory do
  let(:cards_string) { [ card_string1, card_string2, card_string3 ].join(' ') }
  let(:card_string1) { 'card-string-1' }
  let(:card_string2) { 'card-string-2' }
  let(:card_string3) { 'card-string-3' }

  let(:cards) { [ card1, card2, card3 ] }

  let(:card1) { double 'card1' }
  let(:card2) { double 'card2' }
  let(:card3) { double 'card3' }

  before do
    allow(Card).to receive(:new).with(card_string1) { card1 }
    allow(Card).to receive(:new).with(card_string2) { card2 }
    allow(Card).to receive(:new).with(card_string3) { card3 }
  end

  describe '#build' do
    it 'returns cards from strings' do
      expect(subject.build(cards_string)).to eq(cards)
    end
  end
end

describe TexasHoldEm do
  subject { described_class.new cards_string }

  let(:cards_string) { double 'cards string' }

  let(:cards_validator) { double 'cards validator' }

  let(:cards_factory) { double 'cards factory' }
  let(:cards) { double 'cards' }

  let(:hands_finder) { double 'hands finder' }
  let(:all_hands) { [ two_of_a_kind_hand ] }
  let(:two_of_a_kind_hand) { double 'two of a kind hand', description: 'two of a kind description', high_card: two_of_a_kind_hand_high_card }
  let(:two_of_a_kind_hand_high_card) { '2' }

  let(:best_hand_finder) { double 'best hand finder' }

  before do
    allow(TexasPlayerCardsFactory).to receive(:new) { cards_factory }
    allow(TexasHoldEmCardsValidator).to receive(:new) { cards_validator }

    allow(cards_factory).to receive(:build).with(cards_string) { cards }
    allow(cards_validator).to receive(:validate).with(cards) { true }

    allow(HandsFinder).to receive(:new).with(cards) { hands_finder }

    allow(BestHandFinder).to receive(:new).with(all_hands) { best_hand_finder }
  end

  describe '#best_hand' do
    context 'when there is two of a kind' do
      it 'returns best hand string from two of a kind hand object' do
        expect(hands_finder).to receive(:all_hands) { all_hands }
        expect(best_hand_finder).to receive(:best_hand) { two_of_a_kind_hand }

        expect(subject.best_hand).to eq("#{two_of_a_kind_hand.description} (#{two_of_a_kind_hand.high_card} high)")
      end
    end
  end
end










