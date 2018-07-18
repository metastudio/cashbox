# frozen_string_literal: true

# view object for converted money
class ConvertedMoneyPresenter
  def initialize(money, new_currency)
    @old_amount = money
    @new_currency = new_currency
    @same_currency = same_currency?
  end

  def present
    {
      amount: new_amount,
      old_amount: @old_amount,
      rate: rate,
      updated_at: updated_at,
      total: @same_currency ? @old_amount : new_amount
    }
  end

  private

  def same_currency?
    @old_amount.currency == @new_currency
  end

  def new_amount
    @same_currency ? nil : @old_amount.exchange_to(@new_currency)
  end

  def rate
    @same_currency ? nil : Money.default_bank.get_rate(@old_amount.currency, @new_currency)
  end

  def updated_at
    @same_currency ? nil : Money.default_bank.rates_updated_on
  end
end
