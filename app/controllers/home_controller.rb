class HomeController < ApplicationController
  before_filter :require_organization

  def show
    @bank_accounts = BankAccount.balance
  end
end
