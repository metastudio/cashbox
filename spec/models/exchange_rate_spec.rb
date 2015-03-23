require 'spec_helper'

describe ExchangeRate do
  context 'validation' do
    it { should validate_presence_of(:rates) }
    it { should validate_presence_of(:updated_from_bank_at) }
  end
end
