module BankAccountsHelper
  def colorize(amount)
    if amount > 0
      'positive'
    elsif amount < 0
      'negative'
    else
      'empty'
    end
  end
end
