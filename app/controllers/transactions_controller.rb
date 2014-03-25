class TransactionsController < ApplicationController
  before_action :require_organization
  before_action :set_transaction,  only: :destroy

  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.save
  end

  def destroy
    @transaction.destroy
  end

  private

  def set_transaction
    @transaction = current_organization.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :amount_currency, :category_id, :bank_account_id, :comment)
  end
end
