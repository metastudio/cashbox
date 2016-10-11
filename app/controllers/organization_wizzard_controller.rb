class OrganizationWizzardController < ApplicationController
  layout 'settings'
  before_action :set_organization
  before_action :set_organization_wizzard
  before_action :require_second_step, only: [ :new_account,
    :create_default_accounts, :create_accounts ]
  before_action :require_third_step, only: [ :new_category,
    :create_default_categories, :create_categories ]

  def new_account
    @organization.bank_accounts.build
  end

  def new_category
    @organization.categories.build
  end

  def create_default_accounts
    BankAccount.create_defaults(@organization)
    redirect_to new_category_organization_path
  end

  def create_default_categories
    Category.create_defaults(@organization)
    session[:new_organization] = true
    redirect_to root_path
  end

  def create_accounts
    if @organization.update(bank_accounts_params)
      redirect_to :new_category, notice: "Bank accounts was created successfully."
    else
      @open_form = true
      render :new_account
    end
  end

  def create_categories
    if @organization.update(categories_params)
      flash[:new_organization] = true
      redirect_to root_path, notice: "Categories was created successfully."
    else
      @open_form = true
      render :new_category
    end
  end

  private

  def set_organization
    @organization = current_organization
  end

  def set_organization_wizzard
    @organization_wizzard = OrganizationWizzard.new(@organization)
  end

  def bank_accounts_params
    params.require(:organization).permit(bank_accounts_attributes: [:id,
      :name, :description, :invoice_details, :residue, :currency, :_destroy])
  end

  def categories_params
    params.require(:organization).permit(categories_attributes: [:id, :name,
      :type, :_destroy])
  end

  def require_second_step
    if @organization_wizzard.ready?
      redirect_to root_path
    elsif @organization_wizzard.have_account?
      redirect_to new_category_organization_path
    end
  end

  def require_third_step
    if @organization_wizzard.ready?
      redirect_to root_path
    end
  end
end
