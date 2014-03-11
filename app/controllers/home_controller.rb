class HomeController < ApplicationController
  before_filter :require_organization

  def show
    @bank_accounts = current_organization.bank_accounts
  end
end
