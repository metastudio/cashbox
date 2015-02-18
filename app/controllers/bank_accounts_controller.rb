class BankAccountsController < ApplicationController
  before_action :set_bank_account, only: [:edit, :update, :destroy, :hide, :sort,
    :show]
  before_action :require_organization, only: [:edit, :update, :new, :create,
    :destroy, :hide, :show]

  def new
    @bank_account = current_organization.bank_accounts.build
  end

  def show
    @q = @bank_account.transactions.ransack(params[:q])
    @transactions = @q.result.page(params[:page]).per(50)
  end

  def edit
  end

  def create
    @bank_account = current_organization.bank_accounts.build(bank_account_params)

    if @bank_account.save
      redirect_to organization_path(current_organization), notice: 'Bank account was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @bank_account.update(bank_account_params)
      redirect_to organization_path(current_organization), notice: 'Bank account was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def hide
    @bank_account.toggle!(:visible)
    redirect_to organization_path(current_organization)
  end

  def destroy
    @bank_account.destroy
    redirect_to organization_path(current_organization)
  end

  def sort
    @bank_account.insert_at(params[:position].to_i)
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_account
      @bank_account = current_organization.bank_accounts.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_account_params
      params.require(:bank_account).permit(:name, :description, :currency, :residue)
    end
end
