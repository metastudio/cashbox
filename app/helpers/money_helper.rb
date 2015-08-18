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
    humanized_money_with_symbol(money, symbol_after_without_space: true)
  end
end
