class HomeController < ApplicationController
  before_filter :require_organization

  def show
    @q = current_organization.transactions.ransack(params[:q])
    @transactions = @q.result
    @rub_flow = Money.new(@transactions.rub.sum(:amount_cents), 'rub')
    @usd_flow = Money.new(@transactions.usd.sum(:amount_cents), 'usd')
    @transactions = @transactions.page(params[:page]).per(10)
    @bank_accounts = current_organization.bank_accounts
  end
end
