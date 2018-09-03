# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :require_organization
  before_action :redirect_for_not_ready_organization
  before_action :set_transaction, only: %i[edit update destroy]
  before_action :set_invoice, only: %i[new]
  after_action :update_last_viewed_at, only: %i[create create_transfer]

  def new
    if params[:copy_transaction_id].present?
      @transaction = current_organization.transactions.find(params[:copy_transaction_id])
      @transaction = @transaction.dup

      if @transaction.transfer?
        @transfer = Transfer.new(
          amount:          @transaction.transfer_out.amount,
          bank_account_id: @transaction.transfer_out.bank_account_id,
          reference_id:    @transaction.bank_account_id,
          comission:       @transaction.transfer_out.comission,
          comment:         @transaction.comment,
          date:            @transaction.date,
          calculate_sum:   @transaction.amount
        )
      else
        @transaction.amount = @transaction.amount.abs
        @transaction.date   = Date.current
        @transfer = Transfer.new
      end
    else
      @q = current_organization.transactions.ransack(session[:filter])
      if @invoice.present?
        @transaction = Transaction.new(customer_id: @invoice.customer_id,
          customer_name: current_organization.find_customer_name_by_id(@invoice.customer_id),
          amount: @invoice.amount.to_d, invoice: @invoice)
      else
        @transaction = Transaction.new
        @transfer = Transfer.new
      end
    end
  end

  def create
    @transaction = Transaction.new(transaction_params)
    check_relation_to_curr_org(:transaction)
    @transaction.created_by = current_user
    @transaction.save
    @transaction_dup = @transaction.dup if @transaction.leave_open == '1'
  end

  def create_transfer
    @transfer = Transfer.new(transfer_params)
    check_relation_to_curr_org(:transfer)
    @transfer.created_by = current_user
    if @transfer.save
      @inc_transaction = @transfer.inc_transaction
      @out_transaction = @transfer.out_transaction
      @transfer_dup = @transfer.dup if @transfer.leave_open == '1'
    end
  end

  def edit
  end

  def update
    @success = @transaction.update(transaction_params)
  end

  def destroy
    @transaction.destroy
  end

  private

  def check_relation_to_curr_org(trans)
    tparams = params[trans]
    trans = @transaction || @transfer
    curr_bank_accounts = current_organization.bank_accounts
    trans.bank_account_id = curr_bank_accounts.find_by(id: tparams[:bank_account_id]).try(:id)
    trans.category_id = current_organization.categories.find_by(id: tparams[:category_id]).try(:id) if tparams[:category_id]
    trans.reference_id = curr_bank_accounts.find_by(id: tparams[:reference_id]).try(:id) if tparams[:reference_id]
    trans.customer_id = current_organization.customers.find_by(name: tparams[:customer_name]).try(:id) if trans == @transaction

    if trans == @transaction && trans.customer_id.nil? && tparams[:invoice_id].present?
      trans.customer_id = current_organization.customers.find_by(
        id: current_organization.invoices.find_by(id: tparams[:invoice_id]).try(:customer_id)
      ).try(:id)
    end
  end

  def set_invoice
    @invoice = current_organization.invoices.find(params[:invoice_id]) if params[:invoice_id]
  end

  def set_transaction
    @transaction = current_organization.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(
      :amount, :category_id, :bank_account_id, :comment, :comission,
      :reference_id, :customer_id, :customer_name, :date, :invoice_id, :leave_open,
      transfer_out_attributes: %i[id amount category_id bank_account_id comment comission customer_id date]
    )
  end

  def transfer_params
    params.require(:transfer).permit(
      :amount, :bank_account_id, :reference_id,
      :comment, :comission, :exchange_rate, :date, :calculate_sum, :leave_open,
    )
  end
end
