# frozen_string_literal: true

module Api::V1
  class DebtorsController < BaseOrganizationController
    def index
      debtors = []
      total = 0
      summ_by_currencies = []
      current_organization.invoice_debtors.each do |debtor|
        indebtedness = debtor.indebtedness
        indebtedness.each do |debt|
          amount = ConvertedMoneyPresenter.new(
            debt,
            current_organization.default_currency
          ).present
          debtors.push({
            id: debtor.id,
            name: debtor.name,
            amount: amount
          })
          total += amount[:total]
        end
        indebtedness_summ!(summ_by_currencies, indebtedness)
      end
      render json: {
        debtors: debtors,
        summ_by_currencies: summ_by_currencies,
        total: total
      }.to_json
    end

    private

    def indebtedness_summ!(summ, indebtedness)
      indebtedness.each do |debt|
        name = "All customers (#{debt.currency})"
        search = summ.select { |d| d[:name] == name }.first
        if search.present?
          search[:amount] += debt
        else
          summ.push({
            name: name,
            amount: debt
          })
        end
      end
    end
  end
end
