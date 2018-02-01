require_relative '../card'

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
