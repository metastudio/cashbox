module Api::V1
  class OrganizationsController < ApiController
    before_action :set_organization, only: [:show, :update, :destroy, :total_balances]
    before_action :authorize_organization, only: [:update, :destroy, :total_balances]

    def_param_group :organization do
      param :organization, Hash, required: true, action_aware: true do
        param :name, String, 'Name of the organization', required: true
        param :default_currency, String, 'Currency of the organization', required: true
      end
    end

    api :GET, '/organizations', 'Return organizations'
    def index
      @organizations = current_user.organizations
    end

    api :GET, '/organizations/:id', 'Return organization'
    def show
    end

    api :POST, '/organizations', 'Create organization'
    param_group :organization, OrganizationsController
    def create
      @organization = current_user.organizations.build organization_params

      if @organization.save
        Member.create(user: current_user, organization: @organization, role: 'owner')
        render :show
      else
        render json: @organization.errors, status: :unprocessable_entity
      end
    end

    api :PUT, '/organizations/:id', 'Update organization'
    param_group :organization, OrganizationsController
    def update
      if @organization.update(organization_params)
        render :show
      else
        render json: @organization.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, '/organizations/:id', 'Destroy organization'
    def destroy
      @organization.destroy
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
      params.require(:organization).permit(:name, :default_currency)
    end
  end
end
