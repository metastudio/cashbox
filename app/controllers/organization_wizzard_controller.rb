class OrganizationWizzardController < ApplicationController
  layout 'settings'
  before_action :find_organization, except: :finish

  def new_account
  end

  def new_category
  end

  def finish
    session[:new_organization] = true
    redirect_to root_path
  end

  def default_account
    BankAccount.create_defaults(@organization)
    redirect_to :new_category
  end

  def default_category
    Category.create_defaults(@organization)
    session[:new_organization] = true
    redirect_to root_path
  end

  private

  def find_organization
    @organization = current_user.organizations.find(params[:id])
  end
end
