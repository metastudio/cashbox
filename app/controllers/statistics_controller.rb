# frozen_string_literal: true

class StatisticsController < ApplicationController
  layout 'settings'

  def index
  end

  def balance
    params[:balance_scale] = 'months' if params[:balance_scale].blank?
    params[:balance_step] = 0 if params[:balance_step].blank?
    data = StatisticData::ColumnsChart.new(current_organization)
      .data_balance(params[:balance_scale], params[:balance_step])
    respond_to do |format|
      format.html { redirect_to statistics_path }
      format.json { render json: data }
    end
  end

  def customers_chart
    data = StatisticData::ColumnsChart.new(current_organization)
      .customers_by_months(params[:customers_type])
    respond_to do |format|
      format.json { render json: data }
      format.html { redirect_to statistics_path }
    end
  end

  def income_by_customers
    incomes = StatisticData::RoundChart.new(current_organization)
      .by_customers(:incomes, params[:customers_period])
    respond_to do |format|
      format.json { render json: incomes }
      format.html { redirect_to statistics_path }
    end
  end

  def expense_by_customers
    expenses = StatisticData::RoundChart.new(current_organization)
      .by_customers(:expenses, params[:customers_period])
    respond_to do |format|
      format.json { render json: expenses }
      format.html { redirect_to statistics_path }
    end
  end

  def totals_by_customers
    totals = StatisticData::RoundChart.new(current_organization)
      .totals_by_customers(params[:customers_period])
    respond_to do |format|
      format.json { render json: totals }
      format.html { redirect_to statistics_path }
    end
  end

  def balances_by_customers
    balances = StatisticData::ColumnsChart.new(current_organization)
      .balances_by_customers(params[:customers_period])
    respond_to do |format|
      format.json { render json: balances }
      format.html { redirect_to statistics_path }
    end
  end

  def income_by_categories
    incomes = StatisticData::RoundChart.new(current_organization)
      .by_categories(:incomes, params[:customers_period])
    respond_to do |format|
      format.json { render json: incomes }
      format.html { redirect_to statistics_path }
    end
  end

  def expense_by_categories
    expenses = StatisticData::RoundChart.new(current_organization)
      .by_categories(:expenses, params[:customers_period])
    respond_to do |format|
      format.json { render json: expenses }
      format.html { redirect_to statistics_path }
    end
  end
end
