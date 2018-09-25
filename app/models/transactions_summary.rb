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

  def income
    flows.sum do |flow|
      break flow.income if flow.currency == currency

      flow.income.exchange_to(currency)
    end
  end

  def expense
    flows.sum do |flow|
      break flow.expense if flow.currency == currency

      flow.expense.exchange_to(currency)
    end
  end

  def total
    income + expense
  end

  private

  def flows
    @flows ||= scope.flow_ordered(currency)
  end
end
