class StatisticsController < ApplicationController
  layout 'settings'

  def index

  end

  def income_by_customers
    incomes = current_organization.by_customers(current_organization.categories.incomes)

    respond_to do |format|
      format.json { render json: incomes }
    end
  end

  def expense_by_customers
    expenses = current_organization.by_customers(current_organization.categories.
      expenses, expense = true)

    respond_to do |format|
      format.json { render json: expenses }
    end
  end
end
