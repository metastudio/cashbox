require 'spec_helper'

describe Currency do
  describe 'ordered' do
    context 'by default' do
      it 'has USD in first' do
        expect(Currency.ordered.first).to eq "USD"
      end
    end

    context 'when RUB is def' do
      it 'has RUB in first' do
        expect(Currency.ordered("RUB").first).to eq "RUB"
      end
    end
  end
end
