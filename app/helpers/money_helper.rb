module MoneyHelper
  include MoneyRails::ActionViewExtension

  def money_with_symbol(money)
    humanized_money_with_symbol(money, symbol_after_without_space: true)
  end

  def bg(amount)
    amount > 0 ? 'bg-success' : 'bg-danger'
  end
end
