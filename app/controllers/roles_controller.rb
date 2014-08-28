class RolesController < ApplicationController

  def index
    @roles = current_organization.roles
  end

  def new
    @role = current_organization.roles.build
  end

  def create
    @role = Role.new(role_params)

    if @role.save
      redirect_to roles_path, notice: 'Role was created successfully'
    else
      render :new
    end
  end

  def show
  end

  def role_params
    params.require(:role).permit(:organization_id, :user_id, :name)
  end
end
