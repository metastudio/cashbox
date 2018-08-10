# frozen_string_literal: true

class TotalsByCurrencyPresenter
  def initialize(debts)
    @debts = debts
  end

  def present
    @debts.map do |debt|
      name = "All customers (#{debt.currency})"
      { name: name, amount: debt }
    end
  end
end
