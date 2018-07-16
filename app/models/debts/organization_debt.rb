# frozen_string_literal: true

module Debts
  class OrganizationDebt < Debts::Debt
    def initialize(organization)
      @instance = organization
      @organization = organization
    end
  end
end
