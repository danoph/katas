require_relative '../best_hand_finder'

describe BestHandFinder do
  subject { described_class.new hands }

  let(:hands) { [ hand1 ] }

  let(:hand1) { double 'hand 1' }

  describe '#best_hand' do
    context 'only one hand in array' do
      it 'returns that one' do
        expect(subject.best_hand).to eq(hand1)
      end
    end
  end
end
