class HomeController < ApplicationController
  before_filter :require_organization

  def show
    @invoices = Invoice.balance
  end
end
