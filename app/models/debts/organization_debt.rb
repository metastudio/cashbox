# frozen_string_literal: true

module Debts
  class OrganizationDebt < Debts::BaseDebt
    def initialize(organization)
      @instance = organization
      @organization = organization
    end
  end
end
