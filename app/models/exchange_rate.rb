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
      end
    end

    def init_rates
      begin
        params = { rates: Money.default_bank.update_rates,
          updated_from_bank_at: Money.default_bank.rates_updated_at
        }
        ExchangeRate.count.zero? ? ExchangeRate.create!(params) : ExchangeRate.last.update!(params)
      rescue Exception => e
        params = YAML.load_file(Rails.root.join('db', 'seeds', 'rates.yml'))
        if ExchangeRate.count.zero?
          ExchangeRate.create!(params).set_bank_rates
        else
          ExchangeRate.last.update!(params).set_bank_rates
        end
      end
    end
  end
end
