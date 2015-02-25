class HomeController < ApplicationController
  before_filter :require_organization

  def show
    # raise params.inspect
    @q = current_organization.transactions.ransack(params[:q])
    @transactions = @q.result
    @rub_inc  = Money.new(@transactions.by_currency("RUB").incomes.sum(:amount_cents), 'rub')
    @rub_exp  = Money.new(@transactions.by_currency("RUB").expenses.sum(:amount_cents), 'rub')
    @rub_flow = @rub_inc + @rub_exp

    @usd_inc  = Money.new(@transactions.by_currency("USD").incomes.sum(:amount_cents), 'usd')
    @usd_exp  = Money.new(@transactions.by_currency("USD").expenses.sum(:amount_cents), 'usd')
    @usd_flow = @usd_inc + @usd_exp
    @transactions  = @transactions.page(params[:page]).per(50)
    @bank_accounts = current_organization.bank_accounts
  end
end
