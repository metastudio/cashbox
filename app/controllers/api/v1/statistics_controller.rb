# frozen_string_literal: true

class Api::V1::StatisticsController < Api::V1::BaseOrganizationController
  after_action :verify_authorized
  before_action :authorize_statistic

  def balance
    params[:balance_scale] = 'months' if params[:balance_scale].blank?
    params[:balance_step] = 0 if params[:balance_step].blank?
    data = StatisticData::ColumnsChart.new(current_organization)
      .data_balance(params[:balance_scale], params[:balance_step])

    render json: BalanceStatisticSerializer.new(current_organization, data)
  end

  private

  def authorize_statistic
    authorize :statistic
  end
end
