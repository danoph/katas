require_relative '../card'
require_relative '../texas_hold_em_card_validator'

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
