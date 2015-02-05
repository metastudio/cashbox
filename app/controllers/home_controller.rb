class HomeController < ApplicationController
  before_filter :require_organization

  def show
    @transactions = current_organization.transactions.with_deleted.page(params[:page]).per(10)
    @bank_accounts = current_organization.bank_accounts
  end
end
