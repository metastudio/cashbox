class UsersController < ApplicationController
  before_filter :find_user, only: [:edit_role, :update_role]

  def index
    @users = current_organization.users
  end

  def edit_role
    @current_role = @user.role_in(current_organization)
  end

  def update_role
    @user.set_role!(current_organization, params[:new_role])
  end

  private

  def find_user
    @user = current_organization.users.find(params[:id])
  end
end
