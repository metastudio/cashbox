class ExchangeRate < ActiveRecord::Base
  validates :rates, presence: true
  validates :updated_from_bank_at, presence: true

  def set_bank_rates
    rates.each_pair do |curr_to_curr, rate|
      currency, to_currency = curr_to_curr.split('_TO_')
      Money.default_bank.set_rate currency, to_currency, rate.to_f
    end
  end

  class << self
    def update_rates
      begin
        ExchangeRate.last.update(
          rates: Money.default_bank.update_rates,
          updated_from_bank_at: Money.default_bank.rates_updated_at
        )
      rescue Exception => e
        Rails.logger.info e
        ExchangeRate.last.set_bank_rates
      end
    end
  end
end
