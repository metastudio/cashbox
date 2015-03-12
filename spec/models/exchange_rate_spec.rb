require 'spec_helper'

describe ExchangeRate do
  context 'validation' do
    it { should validate_presence_of(:rates) }
    it { should validate_presence_of(:updated_from_bank_at) }
  end

  context '#set_bank_rates' do
    rates_fixture = YAML.load_file(Rails.root.join('db', 'seeds', 'rates.yml'))
    let(:er) { ExchangeRate.create(rates_fixture) }

    it 'init default bank rates' do
      expect(er.set_bank_rates).to eq Money.default_bank.rates
    end
  end
end
