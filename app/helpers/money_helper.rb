module MoneyHelper
  include MoneyRails::ActionViewExtension

  def money_sign(money)
    money > 0 ? 'success' : 'danger'
  end

  def money_with_symbol(money)
    humanized_money_with_symbol(money, symbol_after_without_space: true)
  end
end
