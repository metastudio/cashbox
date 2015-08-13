class TransactionsController < ApplicationController
  before_action :require_organization
  before_action :set_transaction,  only: [:edit, :update, :destroy]
  after_action :update_last_viewed_at, only: [:create, :create_transfer]

  def new
    @q = current_organization.transactions.ransack(session[:filter])
    @transaction = Transaction.new
    @transfer = Transfer.new
  end

  def create
    @transaction = Transaction.new(transaction_params)
    check_relation_to_curr_org(:transaction)
    @transaction.save
  end

  def create_transfer
    @transfer = Transfer.new(transfer_params)
    check_relation_to_curr_org(:transfer)
    if @transfer.save
      @inc_transaction = @transfer.inc_transaction
      @out_transaction = @transfer.out_transaction
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

  def check_relation_to_curr_org(trans)
    tparams = params[trans]
    trans = @transaction || @transfer
    curr_bank_accounts = current_organization.bank_accounts
    trans.bank_account_id = curr_bank_accounts.find_by_id(tparams[:bank_account_id]).try(:id)
    trans.category_id =
      current_organization.categories.find_by_id(tparams[:category_id]).try(:id) if tparams[:category_id]
    trans.reference_id =
      curr_bank_accounts.find_by_id(tparams[:reference_id]).try(:id) if tparams[:reference_id]
    trans.customer_id =
      current_organization.customers.find_by_name(tparams[:customer_name]).try(:id) if trans == @transaction
  end

  def set_transaction
    @transaction = current_organization.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :category_id, :bank_account_id,
     :comment, :comission, :reference_id, :customer_id, :customer_name, :date)
  end

  def transfer_params
    params.require(:transfer).permit(:amount, :bank_account_id, :reference_id,
     :comment, :comission, :exchange_rate, :date)
  end
end
