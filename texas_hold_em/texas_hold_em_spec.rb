require 'test/unit'
require './texas_hold_em'

describe Card do
  subject { described_class.new card_string }

  context 'valid card string' do
    let(:card_string) { 'KD' }

    describe '#rank' do
      it 'returns correct rank' do
        expect(subject.rank).to eq('K')
      end
    end

    describe '#suit' do
      it 'returns correct suit' do
        expect(subject.suit).to eq('D')
      end
    end
  end
end

describe TexasHoldEmCardValidator do
  describe '#valid_card?' do
    context 'valid card' do
      let(:card) { Card.new('KD') }

      it 'returns true' do
        expect(subject.valid_card?(card)).to eq(true)
      end
    end

    context 'invalid card' do
      let(:card) { Card.new('2J') }

      it 'returns true' do
        expect(subject.valid_card?(card)).to eq(false)
      end
    end
  end
end

describe TexasHoldEm do
  subject { described_class.new cards }

  describe 'bad cards' do
    let(:cards) { "2C 3C 4C 5C 6C 7C #{ bad_card }" }

    describe 'bad card 1' do
      let(:bad_card) { '1H' }

      it 'does not allow bad cards' do
        expect{ subject }.to raise_error(ArgumentError, "Should not accept #{ bad_card }")
      end
    end

    describe 'bad card 2' do
      let(:bad_card) { '2J' }

      it 'does not allow bad cards' do
        expect{ subject }.to raise_error(ArgumentError, "Should not accept #{ bad_card }")
      end
    end
  end

  describe 'too many cards' do
    let(:cards) { "KD 9H 10D AD JD 6S QD 6D" }

    it 'does not allow more than 7 cards' do
      expect{ subject }.to raise_error(ArgumentError, "Should not accept more than 7 cards")
    end
  end

  describe 'too few cards' do
    let(:cards) { "KD 9H 10D AD JD 6S" }

    it 'does not allow less than 7 cards' do
      expect{ subject }.to raise_error(ArgumentError, "Should not accept fewer than 7 cards")
    end

    describe 'duplicate cards' do
      let(:cards) { "KD 9H 10D AD JD 6S 9H" }

      it 'does not allow duplicate cards' do
        expect{ subject }.to raise_error(ArgumentError, "Should not accept duplicated cards")
      end
    end
  end

  shared_examples "returns expected output" do
    it 'returns best hand' do
      expect(subject.best_hand).to eq(expected_output)
    end
  end

  describe '#best_hand' do
    context 'royal flush' do
      let(:cards) { "KD 9H 10D AD JD 6S QD" }
      let(:expected_output) { "Royal Flush (A high)" }
      it_behaves_like "returns expected output"
    end

    describe 'straight flush' do
      let(:cards) { "KD 9H 10D 9D JD 6S QD" }
      let(:expected_output) { "Straight Flush (K high)"}
      it_behaves_like "returns expected output"
    end

    describe 'four of a kind' do
      let(:cards) { "4C 7D 7H 3S 7C 10H 7S" }
      let(:expected_output) { "Four of a Kind (7 high)" }
      it_behaves_like "returns expected output"
    end

    describe 'full house high card' do
      let(:cards) { "AH AC 2D 2H 2C 5S 8S" }

      it 'returns best hand' do
        expect(subject.best_hand).to eq("Full House (2 high)")
      end
    end

    describe 'flush beats straight' do
      let(:cards) { "2D 4D 6D 7C 8C 9D 10D" }

      it 'returns best hand' do
        expect(subject.best_hand).to eq("Flush (10 high)")
      end
    end

    describe 'flush beats straight with face card' do
      let(:cards) { "2D 4D 6D 7C KC 9D 10D" }

      it 'returns best hand' do
        expect(subject.best_hand).to eq("Flush (10 high)")
      end
    end

    describe 'three of a kind and not full house' do
      let(:cards) { "AH KC 2D 2H 2C 5S 8S" }

      it 'returns best hand' do
        expect(subject.best_hand).to eq("Three of a Kind (2 high)")
      end
    end

    describe 'pick full house and not three of a kind' do
      let(:cards) { "KH KC 2D 2H 2C KS 8S" }

      it 'returns best hand' do
        expect(subject.best_hand).to eq("Full House (K high)")
      end
    end

    describe 'straight' do
      let(:cards) { "2C 4D AH 6S 5D 3C 10S" }

      it 'returns best hand' do
        expect(subject.best_hand).to eq("Straight (6 high)")
      end
    end

    describe 'three of a kind' do
      let(:cards) { "4C 7D QH 3S 7H 10H 7S" }

      it 'returns best hand' do
        expect(subject.best_hand).to eq("Three of a Kind (7 high)")
      end
    end

    describe 'two pair' do
      let(:cards) { "4C 7D QH 3S 7H 10H QS" }

      it 'returns best hand' do
        expect(subject.best_hand).to eq("Two Pair (Q high)")
      end
    end

    describe 'two of a kind' do
      let(:cards) { "4C 7D 2H 3S JD 10H 7S" }

      it 'returns best hand' do
        expect(subject.best_hand).to eq("Two of a Kind (7 high)")
      end
    end

    describe 'high card' do
      let(:cards) { "4C 7D 2H 3S KD 10H 6S" }

      it 'returns best hand' do
        expect(subject.best_hand).to eq("High Card (K high)")
      end
    end
  end
end
