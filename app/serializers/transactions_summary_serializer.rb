# frozen_string_literal: true

class TransactionsSummarySerializer < ApplicationSerializer
  attributes :income, :expense, :total
end
