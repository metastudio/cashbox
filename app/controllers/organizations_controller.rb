class OrganizationsController < ApplicationController
  before_action :find_organization, only: [:show, :edit, :update, :destroy]

  def index
    @organizations = current_user.organizations
  end

  def show
    authorize @organization
    @bank_accounts = current_organization.bank_accounts
  end

  def new
    @organization = Organization.new
    authorize @organization
  end

  def edit
    authorize @organization
  end

  def create
    @organization = current_user.own_organizations.build(organization_params)
    authorize @organization

    if @organization.save
      redirect_to @organization, notice: 'Organization was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    authorize @organization
    if @organization.update(organization_params)
      redirect_to @organization, notice: 'Organization was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize @organization
    @organization.destroy
    redirect_to organizations_url, notice: 'Organization was successfully removed.'
  end

  private

  def find_organization
    @organization = current_user.organizations.find(params[:id])
  end

  def find_own_organization
    @organization = current_user.own_organizations.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name)
  end
end
