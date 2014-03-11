class BankAccountsController < ApplicationController
  before_action :set_bank_account, only: [:edit, :update, :destroy]
  before_action :set_organization, only: [:edit, :update, :new, :create, :destroy]

  def new
    @bank_account = @organization.bank_accounts.build
  end

  def edit
  end

  def create
    @bank_account = @organization.bank_accounts.build(bank_account_params)

    if @bank_account.save
      redirect_to organization_path(@organization), notice: 'Bank account was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @bank_account.update(bank_account_params)
      redirect_to organization_path(@organization), notice: 'Bank account was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @bank_account.destroy
    redirect_to organization_path(@organization)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_account
      @bank_account = BankAccount.find(params[:id])
    end

    def set_organization
      @organization = Organization.find(params[:organization_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_account_params
      params.require(:bank_account).permit(:name, :currency, :description, :balance_cents, :balance_currency)
    end
end
