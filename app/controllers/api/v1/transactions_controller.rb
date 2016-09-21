module Api::V1
  class TransactionsController < OrganizationController
    before_action :set_transaction,  only: [:show, :edit, :update, :destroy]

    def index
      @transactions = current_organization.transactions.page(params[:page]).per(30)
    end

    def show
    end

    def create
      @transaction = current_organization.bank_accounts.find_by(id: transaction_params[:bank_account_id]).transactions.build transaction_params
      @transaction.created_by = current_user

      if @transaction.save
      else
        render json: { error: @transaction.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @transaction.update(transaction_params)
      else
        render json: { error: @transaction.errors }, status: :unprocessable_entity
      end
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
        :comment, :comission, :reference_id, :customer_id, :customer_name, :date,
        :invoice_id, :leave_open, :transfer_out_id)
    end
  end
end
