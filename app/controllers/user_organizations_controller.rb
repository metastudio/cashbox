class UserOrganizationsController < ApplicationController
  before_filter :find_user_organization, only: [:edit, :update]

  def index
    @user_organizations = current_organization.user_organizations.includes(:user)
  end

  def edit
  end

  def update
    @user_organization.update_attributes(user_organization_params)
  end

  private

  def find_user_organization
    authorize(@user_organization = current_organization.user_organizations.find(params[:id]))
  end

  def user_organization_params
    params.require(:user_organization).permit(:role)
  end

  def pundit_user
    UserContext.new(super, params)
  end
end
