module MoneyHelper
  def money_sign(money)
    money > 0 ? 'success' : 'danger'
  end
end
