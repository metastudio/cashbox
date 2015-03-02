class Currency
  def self.ordered(default_currency = "USD")
    currencies = Dictionaries.to_h[:currencies].sort
    i = currencies.index(default_currency)
    currencies[0], currencies[i] = currencies[i], currencies[0]
    currencies
  end
end
