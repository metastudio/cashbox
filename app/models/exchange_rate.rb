class ExchangeRate < ActiveRecord::Base
  validates :rates, presence: true
  validates :updated_from_bank_at, presence: true

  class << self
    def update_rates
      bank = Money.default_bank
      begin
        ExchangeRate.last.update(
          rates: bank.update_rates,
          updated_from_bank_at: bank.rates_updated_at
        )
      rescue Exception => e
        Rails.logger.info e
        bank.import_rates(:json, ExchangeRate.last.rates.to_json)
      end
    end
  end
end
