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
      rates, rates_updated_at =
        begin
          [Money.default_bank.update_rates, Money.default_bank.rates_updated_at]
        rescue Money::Bank::RussianCentralBankFetcher::FetchError => e
          Rails.logger.info "CBR failed: #{e.response}"

          last_db_rates = ExchangeRate.last
          if last_db_rates.present?
            Rails.logger.warn('Couldn\'t update rates from Bank, updating from DB')
            [Hash[last_db_rates.rates.rates.map { |k, v| [k, v.to_f] }], last_db_rates.updated_from_bank_at]
          else
            Rails.logger.warn('Couldn\'t update rates from Bank or DB, updating from yml file')
            rates = YAML.load_file(Rails.root.join('db', 'seeds', 'rates.yml'))
            [rates[:rates], Time.zone.parse(rates[:updated_from_bank_at])]
          end
        end

      ExchangeRate.create!(
        rates:                rates,
        updated_from_bank_at: rates_updated_at
      )
    end
  end
end
