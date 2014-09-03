class UserOrganizationsController < ApplicationController
  before_filter :find_user_organization, only: [:edit, :update]

  def index
    @user_organizations = current_organization.user_organizations.includes(:user)
  end

  def edit
  end

  def update
    @user_organization.update_attributes(role: params[:user_organization][:role])
  end

  private

  def find_user_organization
    @user_organization = current_organization.user_organizations.find(params[:id])
  end
end
