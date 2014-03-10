class HomeController < ApplicationController
  before_filter :require_organization

  def show
    @invoices = Invoice.balance
    @transactions = Transaction.all.page(params[:page]).per(10)
  end
end
