class Currency
  def self.ordered(default_currency = "USD")
    currencies = Dictionaries.to_h[:currencies].sort
    currencies.delete(default_currency)
    currencies.unshift(default_currency)
  end
end
