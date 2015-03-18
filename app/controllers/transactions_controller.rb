class TransactionsController < ApplicationController
  before_action :require_organization
  before_action :set_transaction,  only: [:edit, :update, :destroy]

  def create
    if current_organization.bank_accounts.find_by_id(params[:bank_account_id])
      @transaction = Transaction.new(transaction_params)
      @transaction.save
    end
  end

  def create_transfer
    accounts = current_organization.bank_accounts
    if accounts.find_by_id(params[:bank_account_id]) && accounts.find_by_id(params[:reference_id])
      @transfer = Transfer.new(transfer_params)
      if @transfer.save
        @inc_transaction = @transfer.inc_transaction
        @out_transaction = @transfer.out_transaction
      end
    end
  end

  def edit
  end

  def update
    @success = @transaction.update_attributes(transaction_params)
  end

  def destroy
    @transaction.destroy
  end

  private

  def set_transaction
    @transaction = current_organization.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :category_id, :bank_account_id,
     :comment, :comission, :reference_id)
  end

  def transfer_params
    params.require(:transfer).permit(:amount, :bank_account_id, :reference_id,
     :comment, :comission, :exchange_rate)
  end
end
