# frozen_string_literal: true

module StatisticsHelper
  def statistics_period_tab_class(params, period)
    return 'active' if params[:customers_period].blank? && period == 'current-month' # default period

    return params[:customers_period] == period ? 'active' : nil
  end
end
