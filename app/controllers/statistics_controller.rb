class StatisticsController < ApplicationController
  layout 'settings'

  def index
  end

  def balance
    if params[:scale].present?
      data = current_organization.data_balance(params[:scale])
    else
      data = current_organization.data_balance
    end
    respond_to do |format|
      format.json { render json: data }
    end
  end

  def income_by_customers
    incomes = current_organization.by_customers(:incomes, params[:period])
    respond_to do |format|
      format.json { render json: incomes }
    end
  end

  def expense_by_customers
    expenses = current_organization.by_customers(:expenses, params[:period])
    respond_to do |format|
      format.json { render json: expenses }
    end
  end

  def totals_by_customers
    totals = current_organization.totals_by_customers(params[:period])
    respond_to do |format|
      format.json { render json: totals }
    end
  end

  def balances_by_customers
    balances = current_organization.balances_by_customers(params[:period])
    respond_to do |format|
      format.json { render json: balances }
    end
  end

  def income_by_categories
    incomes = current_organization.by_categories(:incomes, params[:period])
    respond_to do |format|
      format.json { render json: incomes }
    end
  end

  def expense_by_categories
    expenses = current_organization.by_categories(:expenses, params[:period])
    respond_to do |format|
      format.json { render json: expenses }
    end
  end
end
