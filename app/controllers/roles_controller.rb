class RolesController < ApplicationController

  before_filter :find_role, only: [:edit, :update, :destroy]

  def index
    @roles = current_organization.roles
  end

  def new
    @role = current_organization.roles.build
  end

  def edit
  end

  def create
    @role = Role.new(role_params)

    if @role.save
      redirect_to roles_path, notice: 'Role was created successfully'
    else
      render :new
    end
  end

  def update
    if @role.update_attributes(role_params)
      redirect_to roles_path, notice: 'Role was updated successfully'
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    authorize @role
    @role.destroy
    redirect_to roles_path, notice: 'Role was destroed successfully'
  end

  private

  def role_params
    params.require(:role).permit(:organization_id, :user_id, :name)
  end

  def find_role
    @role = current_organization.roles.find(params[:id])
  end
end
