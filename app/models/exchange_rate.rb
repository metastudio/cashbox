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

class ExchangeRate < ApplicationRecord
  validates :rates, presence: true
  validates :updated_from_bank_at, presence: true

  class << self
    def update_rates
      ExchangeRate.create!(
        rates: Money.default_bank.update_rates,
        updated_from_bank_at: Money.default_bank.rates_updated_at
      )
    end
  end
end
