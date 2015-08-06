class OrganizationsController < ApplicationController
  layout 'settings'
  before_action :find_organization, only: [:show, :edit, :update, :destroy, :switch]
  before_action :authorize_organization, only: [:show, :edit, :update, :destroy]

  def index
    @organizations = current_user.organizations
  end

  def show
    session[:current_organization_id] = @organization.id
    @bank_accounts = @organization.bank_accounts.positioned
  end

  def new
    @organization = Organization.new
  end

  def edit
  end

  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      Member.create(user: current_user, organization: @organization, role: 'owner')
      redirect_to @organization, notice: 'Organization was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: 'Organization was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @organization.destroy
    redirect_to organizations_url, notice: 'Organization was successfully removed.'
  end

  def switch
    if request.referrer == organization_url(current_organization)
      session[:current_organization_id] = @organization.id
      redirect_to organization_url(@organization.id)
    else
      session[:current_organization_id] = @organization.id
      redirect_to :back
    end
  end

  private

  def find_organization
    @organization = current_user.organizations.find(params[:id])
  end

  def authorize_organization
    authorize @organization
  end

  def organization_params
    params.require(:organization).permit(:name, :default_currency)
  end
end
