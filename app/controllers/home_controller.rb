class HomeController < ApplicationController
  before_filter :require_organization

  def show
    @q = current_organization.transactions.ransack(params[:q])
    @transactions = @q.result.page(params[:page]).per(10)
    @bank_accounts = current_organization.bank_accounts
  end
end
