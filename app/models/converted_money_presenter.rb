# frozen_string_literal: true

# view object for converted money
class ConvertedMoneyPresenter
  def initialize(money, new_currency)
    @old_amount = money
    @new_currency = new_currency
  end

  def present
    return not_converted if @old_amount.currency == @new_currency
    converted
  end

  def converted
    {
      amount: new_amount,
      old_amount: @old_amount,
      rate: rate,
      updated_at: updated_at,
      total: new_amount
    }
  end

  def not_converted
    {
      amount: nil,
      old_amount: @old_amount,
      rate: nil,
      updated_at: nil,
      total: @old_amount
    }
  end

  private

  def new_amount
    @old_amount.exchange_to(@new_currency)
  end

  def rate
    Money.default_bank.get_rate(@old_amount.currency, @new_currency)
  end

  def updated_at
    I18n.l Money.default_bank.rates_updated_on
  end
end
