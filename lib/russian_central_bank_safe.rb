class RussianCentralBankSafe < Money::Bank::RussianCentralBank
  def exchange(fractional, rate, &block)
    ex = (fractional * BigDecimal.new(rate.to_s))
    if block_given?
      yield ex.to_f
    elsif @rounding_method
      @rounding_method.call(ex.to_f)
    else
      ex.to_d
    end
  end

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
            @rates = Hash[last_db_rates.rates.rates.map { |k,v| [k, v.to_f] }]
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
