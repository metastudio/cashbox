require 'spec_helper'

describe RussianCentralBankSafe do
  describe 'exchange' do
    let(:amount_to_exchange) { 999999999999999 }
    context 'when values > 999999999999999' do
      before do
        Money.add_rate('USD', 'RUB', 100)
      end

      subject { Money.new(amount_to_exchange, 'USD').exchange_to('RUB') }

      it 'doesnt overflow or cut result' do
        expect(subject).to eq Money.new(99999999999999900, 'RUB')
      end
    end
  end
end
