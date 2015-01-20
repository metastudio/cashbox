class TransactionsController < ApplicationController
  before_action :require_organization
  before_action :set_transaction,  only: [:edit, :update, :destroy]

  def create
    if params[:transaction].has_key?(:comission)
      # create_transactions
      # check_transfer_currencies
      comission = params[:transaction][:comission] = params[:transaction][:comission].to_f
      @transaction = Transaction.new(transaction_params)
      @transaction.category_id = Category.find_or_create_by(
        Category::CATEGORY_BANK_INCOME_PARAMS).id
      @transaction.amount
      # @transaction.amount -= comission

      @out_transaction = Transaction.new(transaction_params)
      @out_transaction.bank_account_id, @out_transaction.reference_id =
        @out_transaction.reference_id, @out_transaction.bank_account_id
      @out_transaction.category_id = Category.find_or_create_by(
        Category::CATEGORY_BANK_EXPENSE_PARAMS).id

      @transaction.save
      @out_transaction.save
      # raise [@transaction.errors].inspect
    else
      @transaction = Transaction.new(transaction_params)
      @transaction.save
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

  def check_params
    if params[:transaction][:bank_account_id].empty?
      errors.add(:bank_account_id, "can't be blank")
    end

    if params[:transaction][:amount].to_f < 0
      errors.add(:bank_account_id, "can't be blank")
    end
  end

  def check_transfer_currencies
    first_bank_currency  = BankAccount.find(params[:transaction][:bank_account_id])
    second_bank_currency = BankAccount.find(params[:transaction][:reference_id])
  end

  def determine_currencies

  end

  def create_transactions
    check_params
  end
end
