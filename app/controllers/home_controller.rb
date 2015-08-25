class HomeController < ApplicationController
  before_filter :require_organization
  after_action :update_last_viewed_at

  def show
    @q = current_organization.transactions.ransack(params[:q])
    @transactions = @q.result
    @curr_flow = @transactions.flow_ordered(current_organization.default_currency) if params[:q]
    @transactions = @transactions.without_out(@q.bank_account_id_eq).page(params[:page]).per(50)

    gon.curr_org_exch_rates = current_organization.exchange_rates

    session[:filter] = params[:q]
    @transaction = Transaction.new
  end
end
