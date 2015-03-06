class HomeController < ApplicationController
  before_filter :require_organization

  def show
    @q = current_organization.transactions.ransack(params[:q])
    @transactions = @q.result
    @curr_flow = @transactions.flow_ordered(current_organization.default_currency)
    @transactions  = @transactions.page(params[:page]).per(50)

    gon.current_org_rates = current_organization.rates
  end
end
