# frozen_string_literal: true

class StatisticPolicy < ApplicationPolicy
  def access?
    !!member
  end

  alias balance?                     access?
  alias income_categories?           access?
  alias expense_categories?          access?
  alias income_customers?            access?
  alias expense_customers?           access?
  alias totals_by_customers?         access?
  alias balances_by_customers?       access?
  alias income_customers_by_months?  access?
  alias expense_customers_by_months? access?
end
