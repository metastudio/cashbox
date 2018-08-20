# frozen_string_literal: true

module Api::V1
  class TransactionsController < BaseOrganizationController
    before_action :set_transaction, only: %i[show update destroy]

    def_param_group :transaction do
      param :transaction, Hash, required: true, action_aware: true do
        param :amount, Float, 'Amount', required: true
        param :category_id, Integer, 'Category ID', required: true
        param :bank_account_id, Integer, 'Bank Account ID', required: true
        param :customer_id, Integer, 'Customer ID'
        param :invoice_id, Integer, 'Invoice ID'
        param :comment, String, 'Comment'
        param :date, DateTime, 'DateTime of creation', required: true
        param :reference_id, Integer, 'Reference bank account ID'
        param :comission, Integer, 'Comission'
        param :transfer_out_id, Integer, 'Transfer out ID'
        param :leave_open, [true, false], 'Leave open'
      end
    end

    def_param_group :transfer do
      param :transfer, Hash, required: true, action_aware: true do
        param :amount, Float, 'Amount', required: true
        param :comission, Float, 'Comission'
        param :exchange_rate, Float, 'Exchange Rate'
        param :bank_account_id, Integer, 'Bank Account ID', required: true
        param :comment, String, 'Comment'
        param :date, DateTime, 'DateTime of creation', required: true
        param :reference_id, Integer, 'Reference bank account ID'
        param :comission, Integer, 'Comission'
      end
    end

    api :GET, '/organizations/:organization_id/transactions', 'Return transactions'
    def index
      authorize :transaction

      @q = current_organization.transactions.without_out([]).ransack(params[:q])
      @q.sorts = ['date desc', 'created_at desc'] if @q.sorts.blank?
      @transactions = @q.result.page(params[:page]).per(30)
    end

    api :GET, '/organizations/:organization_id/transactions/:id', 'Return transaction'
    def show
    end

    api :POST, '/organizations/:organization_id/transactions', 'Create transaction'
    param_group :transaction, TransactionsController
    def create
      authorize :transaction

      @transaction = Transaction.new transaction_params.except(:amount)
      bank_account = current_organization.bank_accounts.find_by(id: transaction_params[:bank_account_id])
      @transaction.bank_account = bank_account
      @transaction.amount = transaction_params[:amount]&.to_d
      @transaction.created_by = current_user
      if @transaction.save
        render :show
      else
        render json: @transaction.errors.messages, status: :unprocessable_entity
      end
    end

    api :POST, '/organizations/:organization_id/transactions/transfer', 'Create transfer'
    param_group :transfer, TransactionsController
    def create_transfer
      authorize :transaction

      @transfer = Transfer.new(transfer_params)
      @transfer.created_by = current_user
      if @transfer.save
        @inc_transaction = @transfer.inc_transaction
        @out_transaction = @transfer.out_transaction
        @transaction = @inc_transaction
        render :show
      else
        render json: @transfer.errors.messages, status: :unprocessable_entity
      end
    end

    api :PUT, '/organizations/:organization_id/transactions/:id', 'Update transaction'
    param_group :transaction, TransactionsController
    def update
      if @transaction.update(transaction_params)
        render :show
      else
        render json: @transaction.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, '/organizations/:organization_id/transactions/:id', 'Destroy transaction'
    def destroy
      @transaction.destroy
    end

    private

    def set_transaction
      @transaction = current_organization.transactions.find(params[:id])
      authorize @transaction
    end

    def transaction_params
      params.fetch(:transaction, {}).permit(:amount, :category_id, :bank_account_id,
        :comment, :comission, :reference_id, :customer_id, :customer_name, :date,
        :invoice_id, :leave_open, :transfer_out_id,
        transfer_out_attributes: %i[
          id amount category_id bank_account_id comment comission customer_id date
        ])
    end

    def transfer_params
      params.fetch(:transfer, {}).permit(:amount, :bank_account_id, :reference_id,
        :comment, :comission, :exchange_rate, :date, :calculate_sum)
    end
  end
end
