class RussianCentralBankSafe < Money::Bank::RussianCentralBank
  def update_rates(date = Date.today)
      @mutex.synchronize{
        begin
          update_parsed_rates exchange_rates(date)
          @rates_updated_at = Time.now
          @rates_updated_on = date
          @rates
        rescue Exception => e
          begin
            last_db_rates = ExchangeRate.last
            @rates_updated_at = last_db_rates.updated_from_bank_at
            @rates_updated_on = date
            @rates = last_db_rates.rates
          rescue Exception => e
            rates = YAML.load_file(Rails.root.join('db', 'seeds', 'rates.yml'))
            @rates_updated_at = DateTime.parse(rates[:updated_from_bank_at])
            @rates_updated_on = date
            @rates = rates[:rates]
          end
        end
      }
  end
end
