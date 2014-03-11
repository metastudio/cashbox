class TransactionsController < ApplicationController
  before_action :set_transaction,  only: :destroy
  before_action :set_transactions, only: :create

  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.save
  end

  def destroy
    @transaction.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def set_transactions
      @transactions = Transaction.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:amount, :amount_currency, :category_id, :bank_account_id)
    end
end
