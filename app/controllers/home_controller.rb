class HomeController < ApplicationController
  before_filter :require_organization

  def show
    @q = current_organization.transactions.ransack(params[:q])
    @transactions = @q.result
    @curr_flow = @transactions.flow_ordered(current_organization.default_currency) if params[:q]
    @transactions = @transactions.page(params[:page]).per(50)
    Money.default_bank.update_rates
    gon.curr_org_exch_rates = current_organization.exchange_rates
  end
end
