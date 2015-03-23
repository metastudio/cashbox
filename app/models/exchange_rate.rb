class ExchangeRate < ActiveRecord::Base
  validates :rates, presence: true
  validates :updated_from_bank_at, presence: true

  class << self
    def update_rates
      ExchangeRate.last.update(
        rates: Money.default_bank.update_rates,
        updated_from_bank_at: Money.default_bank.rates_updated_at
      )
    end
  end
end
