module MoneyHelper
  include MoneyRails::ActionViewExtension

  def colorize_amount(amount)
    if amount > 0
      'positive'
    elsif amount < 0
      'negative'
    else
      'empty'
    end
  end

  def colorize_ba_amount(amount)
    'negative-text' if amount < 0
  end

  def total_colorize_amount(amount)
    if amount > 0
      'positive total'
    elsif amount < 0
      'negative total'
    else
      'empty'
    end
  end

  def money_with_symbol(money)
    humanized_money_with_symbol(money, symbol_currency_format(money.currency.iso_code))
  end

  def symbol_currency_format(default_currency)
    return if default_currency == nil
    return { sign_before_symbol: false, format: '%n%u' } if %w(RUB RSD).include?(default_currency)
    {}
  end
end
