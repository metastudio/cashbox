class HomeController < ApplicationController
  before_filter :require_organization
  after_action :update_last_viewed_at

  def show
    @q = current_organization.transactions.ransack(params[:q])
    @q.sorts = ['date desc', 'created_at desc'] if @q.sorts.blank?
    @transactions = @q.result
    @curr_flow = @transactions.flow_ordered(current_organization.default_currency) if params[:q]
    if params[:q] && params[:q][:category_type_eq]
      @transactions = @transactions.page(params[:page]).per(50)
    else
      @transactions = @transactions.without_out(@q.bank_account_id_in).page(params[:page]).per(50)
    end
    gon.curr_org_exch_rates = current_organization.exchange_rates

    session[:filter] = params[:q]
    @transaction = Transaction.new
  end
end
