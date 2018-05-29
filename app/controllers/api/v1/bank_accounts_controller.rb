module Api::V1
  class BankAccountsController < BaseOrganizationController
    before_action :set_bank_account, only: [:show, :update, :destroy]

    def_param_group :bank_account do
      param :bank_account, Hash, required: true, action_aware: true do
        param :name, String, 'Name', required: true
        param :description, String, 'Description'
        param :currency, String, 'Currency', required: true
        param :residue, Integer, 'Residue', required: true
        param :invoice_details, String, 'Invoice Details'
      end
    end

    api :GET, '/organizations/:organization_id/bank_accounts', 'Return bank accounts for current organization'
    def index
      @bank_accounts = current_organization.bank_accounts.positioned
    end

    api :GET, '/organizations/:organization_id/bank_accounts/:id', 'Return bank account'
    def show
    end

    api :POST, '/organizations/:organization_id/bank_accounts', 'Create bank account'
    param_group :bank_account, BankAccountsController
    def create
      @bank_account = current_organization.bank_accounts.build bank_account_params
      if @bank_account.save
        render :show
      else
        render json: @bank_account.errors, status: :unprocessable_entity
      end
    end

    api :PUT, '/organizations/:organization_id/bank_accounts/:id', 'Update bank account'
    param_group :bank_account, BankAccountsController
    def update
      if @bank_account.update(bank_account_params)
        render :show
      else
        render json: @bank_account.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, '/organizations/:organization_id/bank_accounts/:id', 'Destroy bank account'
    def destroy
      @bank_account.destroy
      render :show
    end

    private

    def set_bank_account
      @bank_account = current_organization.bank_accounts.find(params[:id])
    end

    def bank_account_params
      params.fetch(:bank_account, {}).permit(:name, :description, :currency, :residue, :invoice_details)
    end
  end
end
