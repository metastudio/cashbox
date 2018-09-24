# frozen_string_literal: true

class Api::V1::OrganizationsController < Api::V1::BaseController
  before_action :set_organization, only: %i[show update destroy total_balances]
  before_action :authorize_organization, only: %i[update destroy total_balances]

  def_param_group :organization do
    param :organization, Hash, required: true, action_aware: true do
      param :name, String, 'Name of the organization', required: true
      param :default_currency, String, 'Default currency for the organization'
    end
  end

  api :GET, '/organizations', 'Return organizations associated with the current user'
  def index
    @organizations = current_user.organizations
    render json: @organizations
  end

  api :GET, '/organizations/:id', 'Return organization'
  def show
    render json: @organization
  end

  api :POST, '/organizations', 'Create organization'
  param_group :organization, Api::V1::OrganizationsController
  def create
    @organization = current_user.organizations.build(organization_params)

    if @organization.save
      @organization.members.create(user: current_user, role: 'owner')
      render json: @organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  api :PUT, '/organizations/:id', 'Update organization'
  param_group :organization, Api::V1::OrganizationsController
  def update
    if @organization.update(organization_params)
      render json: @organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  api :DELETE, '/organizations/:id', 'Destroy organization'
  def destroy
    if @organization.destroy
      render json: @organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end

  api :GET, 'organizations/:id/total_balances', 'Return total balances'
  def total_balances
  end

  private

  def set_organization
    @organization = current_user.organizations.find(params[:id])
  end

  def authorize_organization
    authorize @organization
  end

  def organization_params
    params.fetch(:organization, {}).permit(:name, :default_currency)
  end
end
