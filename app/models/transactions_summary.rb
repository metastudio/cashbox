# frozen_string_literal: true

class TransactionsSummary
  # This alias is needed for AMS to work
  alias read_attribute_for_serialization send

  attr_reader :scope
  attr_reader :currency

  # This method is needed for AMS to work
  def self.model_name
    @_model_name ||= ActiveModel::Name.new(self) # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def initialize(transactions_scope, default_currency)
    @scope    = transactions_scope
    @currency = default_currency
  end

  def currencies
    flows.map(&:currency)
  end

  def income(currency)
    flows.find{ |f| f.currency == currency }&.income
  end

  def expense(currency)
    flows.find{ |f| f.currency == currency }&.expense
  end

  def difference(currency)
    flows.find{ |f| f.currency == currency }&.total
  end

  def total_income
    @total_income ||= flows.sum{ |f| f.income.exchange_to(currency) }
  end

  def total_expense
    @total_expense ||= flows.sum{ |f| f.expense.exchange_to(currency) }
  end

  def total_difference
    @total_difference ||= flows.sum{ |f| f.total.exchange_to(currency) }
  end

  private

  def flows
    @flows ||= scope.flow_ordered(currency)
  end
end
