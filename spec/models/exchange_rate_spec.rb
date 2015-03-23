# == Schema Information
#
# Table name: exchange_rates
#
#  id                   :integer          not null, primary key
#  rates                :hstore           not null
#  updated_from_bank_at :datetime         not null
#  created_at           :datetime
#  updated_at           :datetime
#

require 'spec_helper'

describe ExchangeRate do
  context 'validation' do
    it { should validate_presence_of(:rates) }
    it { should validate_presence_of(:updated_from_bank_at) }
  end
end
