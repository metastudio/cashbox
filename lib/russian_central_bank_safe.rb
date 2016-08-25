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

  def update_rates(date = Date.current)
    logger = Rails.logger
    begin
      update_parsed_rates exchange_rates(date)
      @rates_updated_at = date.beginning_of_day
      @rates_updated_on = date
      update_expired_at
      logger.info('Updated rates from Bank')
      @rates
    rescue Exception => e
      begin
        last_db_rates = ExchangeRate.last
        @rates_updated_at = last_db_rates.updated_from_bank_at
        @rates_updated_on = date
        logger.warn('Couldn\'t update rates from Bank, updating from DB')
        @rates = Hash[last_db_rates.rates.rates.map { |k,v| [k, v.to_f] }]
      rescue Exception => e
        rates = YAML.load_file(Rails.root.join('db', 'seeds', 'rates.yml'))
        @rates_updated_at = DateTime.parse(rates[:updated_from_bank_at])
        @rates_updated_on = date
        logger.warn('Couldn\'t update rates from Bank or DB, updating from yml file')
        @rates = rates[:rates]
      end
    end
  end

  private

    def exchange_rates(date = Date.today)
      client = Savon::Client.new wsdl: CBR_SERVICE_URL, log: false, log_level: :error,
        follow_redirects: true, open_timeout: 2, read_timeout: 2
      response = client.call(:get_curs_on_date, message: { 'On_date' => date.strftime('%Y-%m-%dT%H:%M:%S') })
      response.body[:get_curs_on_date_response][:get_curs_on_date_result][:diffgram][:valute_data][:valute_curs_on_date]
    end

end
