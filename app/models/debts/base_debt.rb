# frozen_string_literal: true

module Debts
  # don't use this class directly, use OrganizationDebt or CustomerDebt
  class BaseDebt
    # basicaly instance can be organization or customer instance
    def initialize(instance)
      @instance = instance
    end

    def by_currency
      invoices_group_by_currency.map do |currency, amount_cents|
        Money.new(amount_cents, currency)
      end
    end

    def total
      def_curr = @organization.default_currency
      invoices_group_by_currency.inject(0) do |total, invoice|
        currency, amount_cents = invoice
        m = Money.new(amount_cents, currency)
        return m + total if def_curr == currency
        m.exchange_to(def_curr) + total
      end
    end

    private

    def invoices_group_by_currency
      return @invoices_group_by_currency if @invoices_group_by_currency.present?
      @invoices_group_by_currency = @instance
        .invoices
        .unpaid
        .group(:currency)
        .sum(:amount_cents)
    end
  end
end
