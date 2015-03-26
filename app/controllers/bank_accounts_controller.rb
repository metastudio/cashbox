class BankAccountsController < ApplicationController
  layout 'settings'
  before_action :set_bank_account, only: [:edit, :update, :destroy, :hide]
  before_action :require_organization, only: [:edit, :update, :new, :create,
    :destroy, :hide]
  before_action :find_bank_account, only: :sort

  def new
    @bank_account = current_organization.bank_accounts.build
  end

  def index
    @bank_accounts = current_organization.bank_accounts.positioned
  end

  def edit
  end

  def create
    @bank_account = current_organization.bank_accounts.build(bank_account_params)

    if @bank_account.save
      redirect_to bank_accounts_path, notice: 'Bank account was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @bank_account.update(bank_account_params)
      redirect_to bank_accounts_path, notice: 'Bank account was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def hide
    @bank_account.toggle!(:visible)
    redirect_to bank_accounts_path
  end

  def destroy
    @bank_account.destroy
    redirect_to bank_accounts_path
  end

  def sort
    authorize @bank_account.organization, :update?

    @bank_account.insert_at(params[:position].to_i)
    render nothing: true
  end

  private
    def find_bank_account
      @bank_account = BankAccount.find(params[:id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_bank_account
      @bank_account = current_organization.bank_accounts.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_account_params
      params.require(:bank_account).permit(:name, :description, :currency, :residue)
    end

    def pundit_user
      current_user
    end
end
