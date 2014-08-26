class TransactionsController < ApplicationController
  before_action :require_organization
  before_action :set_transaction,  only: [:edit, :update, :destroy]

  def create
    @fixed_category = Category.find(params[:transaction][:fixed_category_id]) if params[:transaction][:fixed_category_id].present?
    @transaction = Transaction.new(transaction_params)
    @transaction.category = @fixed_category if @fixed_category.present?
    @transaction.save
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
    params.require(:transaction).permit(:amount, :category_id, :bank_account_id, :comment, :fixed_category_id)
  end
end
