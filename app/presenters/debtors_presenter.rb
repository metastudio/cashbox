# frozen_string_literal: true

# View for debtors api request
class DebtorsPresenter
  def initialize(organization)
    @organization = organization
  end

  def present
    debtors = []
    total = 0
    totals_by_currency = []
    @organization.invoice_debtors.each do |debtor|
      indebtedness = debtor.indebtedness
      indebtedness.each do |debt|
        amount = ConvertedMoneyPresenter.new(
          debt,
          @organization.default_currency
        ).present
        debtors.push({
          id: debtor.id,
          name: debtor.name,
          amount: amount
        })
        total += amount[:total]
      end
      indebtedness_summ!(totals_by_currency, indebtedness)
    end
    {
      debtors: debtors,
      totals_by_currency: totals_by_currency,
      total: total
    }
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
