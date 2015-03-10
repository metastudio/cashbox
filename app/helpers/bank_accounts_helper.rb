module BankAccountsHelper
  def colorize(amount)
    if amount > 0
      AppConfig.account_colors.negative.css_class
    elsif amount < 0
      AppConfig.account_colors.positive.css_class
    else
      AppConfig.account_colors.empty.css_class
    end
  end
end
