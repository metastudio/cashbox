# frozen_string_literal: true

# View for debtors api request
class DebtorsPresenter
  def initialize(organization)
    @organization = organization
  end

  def present
    org_debt = Debts::OrganizationDebt.new(@organization)
    debtors = @organization.invoice_debtors.map do |debtor|
      debtor_debts = Debts::CustomerDebt.new(debtor)
      amounts = debtor_debts.by_currency.map do |debt|
        ConvertedMoneyPresenter.new(
          debt,
          @organization.default_currency
        ).present
      end
      { id: debtor.id, name: debtor.name, amounts: amounts }
    end
    { debtors: debtors, totals_by_currency: TotalsByCurrencyPresenter.new(org_debt.by_currency).present, total: org_debt.total }
  end
end
