# frozen_string_literal: true

class TransactionsSummarySerializer
  attr_reader :summary

  def initialize(summary)
    @summary = summary
  end

  def as_json(_opts)
    json = {}.tap do |j|
      summary.currencies.each do |currency|
        j[currency] = {
          income:     summary.income(currency),
          expense:    summary.expense(currency),
          difference: summary.difference(currency),
        }
      end

      j[:total] = {
        income:     summary.total_income,
        expense:    summary.total_expense,
        difference: summary.total_difference,
      }
    end

    { transactions_summary: json }
  end
end
