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

  def money_with_symbol(money)
    humanized_money_with_symbol(money, symbol_after_without_space: true)
  end
end
