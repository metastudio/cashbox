class UserOrganizationsController < ApplicationController
  before_filter :find_user_organization, only: [:edit, :update]
  before_filter :authorize_user_organization, except: [:index]

  def index
    @user_organizations = current_organization.user_organizations.includes(:user)
  end

  def edit
  end

  def update
    if params[:user_organization][:role] == 'owner' && !current_user_organization.owner?
      raise Pundit::NotAuthorizedError, "You have no permissions"
    end

    @user_organization.update_attributes(role: params[:user_organization][:role])
  end

  private

  def find_user_organization
    @user_organization = current_organization.user_organizations.find(params[:id])
  end

  def authorize_user_organization
    authorize @user_organization
  end
end
