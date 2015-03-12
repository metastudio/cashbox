require 'spec_helper'

describe Currency do
  describe 'ordered' do
    context 'by default' do
      it 'has USD in first' do
        expect(Currency.ordered).to eq ['USD','EUR','RUB']
      end
    end

    context 'when RUB is def' do
      it 'has RUB in first' do
        expect(Currency.ordered('RUB')).to eq ['RUB', 'EUR','USD']
      end
    end
  end
end
