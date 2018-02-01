require_relative '../hands_finder'

describe TwoOfAKind do
  subject { described_class.new cards }

  let(:cards) { [ card1, card2, high_card ] }

  let(:card1) { '1' }
  let(:card2) { '2' }
  let(:high_card) { '3' }

  describe '#description' do
    it 'returns string' do
      expect(subject.description).to eq('Two of a Kind')
    end
  end

  describe '#high_card' do
    it 'returns highest card' do
      expect(subject.high_card).to eq(high_card)
    end
  end
end

describe HandsFinder do
  subject { described_class.new cards }

  let(:cards) { [ card1, card2, card3, card4, card5, card6, card7 ] }

  let(:card1) { double 'card1', rank: rank1 }
  let(:card2) { double 'card2', rank: rank2 }
  let(:card3) { double 'card3', rank: rank3 }
  let(:card4) { double 'card4', rank: rank4 }
  let(:card5) { double 'card5', rank: rank5 }
  let(:card6) { double 'card6', rank: rank6 }
  let(:card7) { double 'card7', rank: rank2 }

  let(:rank1) { double 'rank1' }
  let(:rank2) { double 'rank2' }
  let(:rank3) { double 'rank3' }
  let(:rank4) { double 'rank4' }
  let(:rank5) { double 'rank5' }
  let(:rank6) { double 'rank6' }

  let(:two_of_a_kind_hand) { double 'two of a kind hand' }

  describe '#all_hands' do
    context 'two of a kind' do
      before do
        allow(TwoOfAKind).to receive(:new).with([ card2, card7 ]) { two_of_a_kind_hand }
      end

      it 'returns an array with two of a kind hand in the array' do
        expect(subject.all_hands).to eq([ two_of_a_kind_hand ])
      end
    end
  end
end
