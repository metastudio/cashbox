class StatisticsController < ApplicationController
  layout 'settings'
  respond_to :json, except: :index

  def index
  end

  def balance
    params[:scale] = 'months' if params[:scale].blank?
    params[:step] = 0 if params[:step].blank?
    data = StatisticData::ColumnsChart.new(current_organization)
      .data_balance(params[:scale], params[:step])
    respond_with(data)
  end

  def customers_chart
    data = StatisticData::ColumnsChart.new(current_organization)
      .customers_by_months(params[:type])
    respond_with(data)
  end

  def income_by_customers
    incomes = StatisticData::RoundChart.new(current_organization)
      .by_customers(:incomes, params[:period])
    respond_with(incomes)
  end

  def expense_by_customers
    expenses = StatisticData::RoundChart.new(current_organization)
      .by_customers(:expenses, params[:period])
    respond_with(expenses)
  end

  def totals_by_customers
    totals = StatisticData::RoundChart.new(current_organization)
      .totals_by_customers(params[:period])
    respond_with(totals)
  end

  def balances_by_customers
    balances = StatisticData::ColumnsChart.new(current_organization)
      .balances_by_customers(params[:period])
    respond_with(balances)
  end

  def income_by_categories
    incomes = StatisticData::RoundChart.new(current_organization)
      .by_categories(:incomes, params[:period])
    respond_with(incomes)
  end

  def expense_by_categories
    expenses = StatisticData::RoundChart.new(current_organization)
      .by_categories(:expenses, params[:period])
    respond_with(expenses)
  end
end
