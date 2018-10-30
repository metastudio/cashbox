# frozen_string_literal: true

class Api::V1::StatisticsController < Api::V1::BaseOrganizationController
  after_action :verify_authorized
  before_action :authorize_statistic

  def balance
    params[:scale] = 'months' if params[:scale].blank?
    params[:page] = 0 if params[:page].blank?
    data = StatisticData::ColumnsChart.new(current_organization)
      .data_balance(params[:scale], params[:page])

    render json: {
      statistic:  BalanceStatisticSerializer.new(current_organization, data),
      pagination: PaginationSerializer.new(Pagination.new({
        current:  params[:page],
        previous: params[:page].to_i.positive? ? params[:page].to_i - 1 : nil,
        next:     data[:next_step_blank] ? nil : params[:page].to_i + 1,
      })),
    }
  end

  private

  def authorize_statistic
    authorize :statistic
  end
end
