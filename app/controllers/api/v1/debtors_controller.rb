# frozen_string_literal: true

module Api::V1
  class DebtorsController < BaseOrganizationController
    def index
      debtors = []
      current_organization.invoice_debtors.each do |debtor|
        debtor.indebtedness.each do |debt|
          debtors.push({
            id: debtor.id,
            name: debtor.name,
            amount: ConvertedMoneyPresenter.new(
              debt,
              current_organization.default_currency
            ).present
          })
        end
      end
      render json: debtors.to_json
    end
  end
end
