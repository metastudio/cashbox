class StatisticsController < ApplicationController
  layout 'settings'

  def index
  end

  def balance
    data = current_organization.data_balance
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
