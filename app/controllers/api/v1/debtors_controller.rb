# frozen_string_literal: true

module Api::V1
  class DebtorsController < BaseOrganizationController
    def index
      @debtors = current_organization.invoice_debtors
    end
  end
end
