module MoneyHelper
  include MoneyRails::ActionViewExtension

  def colorize_amount(amount)
    amount > 0 ? 'positive' : (amount < 0 ? 'negative' : 'empty')
  end

  def darken_colorize_amount(amount)
    amount > 0 ? 'positive darken' : (amount < 0 ? 'negative darken' : 'empty')
  end

  def money_with_symbol(money)
    humanized_money_with_symbol(money, symbol_after_without_space: true)
  end
end
