# frozen_string_literal: true

class Api::V1::StatisticsController < Api::V1::BaseOrganizationController
  after_action :verify_authorized
  before_action :authorize_statistic

  def balance
    scale = params[:scale].presence || 'months'
    params[:page] = 0 if params[:page].blank?
    data = StatisticData::ColumnsChart.new(current_organization)
      .data_balance(scale, params[:page])

    render json: {
      statistic:  BalanceStatisticSerializer.new(current_organization, data),
      pagination: PaginationSerializer.new(Pagination.new({
        current:  params[:page],
        previous: params[:page].to_i.positive? ? params[:page].to_i - 1 : nil,
        next:     data[:next_step_blank] ? nil : params[:page].to_i + 1,
      })),
    }
  end

  def income_categories
    period = params[:period].presence || 'current-month'
    data = StatisticData::RoundChart.new(current_organization)
      .by_categories(:incomes, period)

    render json: {
      statistic: CategoriesStatisticSerializer.new(current_organization, data),
    }
  end

  def expense_categories
    period = params[:period].presence || 'current-month'
    data = StatisticData::RoundChart.new(current_organization)
      .by_categories(:expenses, period)

    render json: {
      statistic: CategoriesStatisticSerializer.new(current_organization, data),
    }
  end

  def income_customers
    period = params[:period].presence || 'current-month'
    data = StatisticData::RoundChart.new(current_organization)
      .by_customers(:incomes, period)

    render json: {
      statistic: CustomersStatisticSerializer.new(current_organization, data),
    }
  end

  def expense_customers
    period = params[:period].presence || 'current-month'
    data = StatisticData::RoundChart.new(current_organization)
      .by_customers(:expenses, period)

    render json: {
      statistic: CustomersStatisticSerializer.new(current_organization, data),
    }
  end

  def totals_by_customers
    period = params[:period].presence || 'current-month'
    data = StatisticData::RoundChart.new(current_organization)
      .totals_by_customers(period)
    render json: {
      statistic: CustomersStatisticSerializer.new(current_organization, data),
    }
  end

  def balances_by_customers
    period = params[:period].presence || 'current-month'
    data = StatisticData::ColumnsChart.new(current_organization)
      .balances_by_customers(period)
    render json: {
      statistic: CustomersBalancesStatisticSerializer.new(current_organization, data),
    }
  end

  private

  def authorize_statistic
    authorize :statistic
  end
end
