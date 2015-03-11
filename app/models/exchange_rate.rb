class ExchangeRate < ActiveRecord::Base
  class << self
    def update_rates
      begin
        bank = Money::Bank::RussianCentralBank.new
        bank.update_rates
        ExchangeRate.last.update_attribute :rates, bank.rates
      rescue Exception => e
        Rails.logger.info e
        update_attribute :rates, ExchangeRate.last.rates
      end
    end
  end
end
