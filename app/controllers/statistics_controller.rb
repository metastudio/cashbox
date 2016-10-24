class StatisticsController < ApplicationController
  layout 'settings'

  def index
  end

  def balance
    if params[:balance_scale].present? && params[:balance_step].present?
      data = current_organization.data_balance(params[:balance_scale], params[:balance_step])
    elsif params[:balance_scale].present?
      data = current_organization.data_balance(params[:balance_scale])
    elsif params[:balance_step].present?
      data = current_organization.data_balance('months', params[:balance_step])
    else
      data = current_organization.data_balance
    end
    respond_to do |format|
      format.json { render json: data }
      format.html { redirect_to statistics_path }
    end
  end

  def customers_chart
    data = current_organization.customers_by_months(params[:customers_type])
    respond_to do |format|
      format.json { render json: data }
      format.html { redirect_to statistics_path }
    end
  end

  def income_by_customers
    incomes = current_organization.by_customers(:incomes, params[:customers_period])
    respond_to do |format|
      format.json { render json: incomes }
      format.html { redirect_to statistics_path }
    end
  end

  def expense_by_customers
    expenses = current_organization.by_customers(:expenses, params[:customers_period])
    respond_to do |format|
      format.json { render json: expenses }
      format.html { redirect_to statistics_path }
    end
  end

  def totals_by_customers
    totals = current_organization.totals_by_customers(params[:customers_period])
    respond_to do |format|
      format.json { render json: totals }
      format.html { redirect_to statistics_path }
    end
  end

  def balances_by_customers
    balances = current_organization.balances_by_customers(params[:customers_period])
    respond_to do |format|
      format.json { render json: balances }
      format.html { redirect_to statistics_path }
    end
  end

  def income_by_categories
    incomes = current_organization.by_categories(:incomes, params[:customers_period])
    respond_to do |format|
      format.json { render json: incomes }
      format.html { redirect_to statistics_path }
    end
  end

  def expense_by_categories
    expenses = current_organization.by_categories(:expenses, params[:customers_period])
    respond_to do |format|
      format.json { render json: expenses }
      format.html { redirect_to statistics_path }
    end
  end
end
