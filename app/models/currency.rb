class Currency
  def self.ordered(default_currency = "USD")
    currencies = Dictionaries.currencies.sort
    currencies.delete(default_currency)
    currencies.unshift(default_currency)
  end
end
