# frozen_string_literal: true

module Debts
  class OrganizationDebt
    include DebtConcern

    def total
      def_curr = @instance.default_currency
      invoices_group_by_currency.inject(0) do |total, invoice|
        currency, amount_cents = invoice
        m = Money.new(amount_cents, currency)
        return m + total if def_curr == currency
        m.exchange_to(def_curr) + total
      end
    end
  end
end
