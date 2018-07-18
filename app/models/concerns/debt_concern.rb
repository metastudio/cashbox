# frozen_string_literal: true

module DebtConcern
  extend ActiveSupport::Concern

  def initialize(instance)
    @instance = instance
  end

  def by_currency
    invoices_group_by_currency.map do |currency, amount_cents|
      Money.new(amount_cents, currency)
    end
  end

  private

  def invoices_group_by_currency
    @invoices_group_by_currency ||= @instance
      .invoices
      .unpaid
      .group(:currency)
      .sum(:amount_cents)
  end
end
