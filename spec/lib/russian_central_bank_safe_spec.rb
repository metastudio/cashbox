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

  describe 'update rates' do
    before do
      Money.default_bank.add_rate('USD', 'RUB', -1)
      Money.default_bank.update_rates
    end

    context 'return updated bank rates' do
      subject { Money.default_bank.get_rate('USD', 'RUB') }

      it 'does update rates' do
        expect(subject).to_not eq -1
      end
    end

    context 'return hash class' do
      subject { Money.default_bank.update_rates }

      it 'does update rates' do
        expect(subject.class).to eq Hash
      end
    end
  end
end
