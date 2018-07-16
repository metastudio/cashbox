# frozen_string_literal: true

module Debts
  class CustomerDebt < Debts::BaseDebt
    def initialize(customer)
      @instance = customer
      @organization = customer.organization
    end
  end
end
