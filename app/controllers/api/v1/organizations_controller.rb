module Api::V1
  class OrganizationsController < ApiController
    before_action :set_organization, only: [:show, :update, :destroy]
    before_action :authorize_organization, only: [:update, :destroy]

    api!
    def index
      @organizations = current_user.organizations
    end

    api!
    def show
    end

    def create
      @organization = current_user.organizations.build organization_params

      if @organization.save
        Member.create(user: current_user, organization: @organization, role: 'owner')
      else
        render json: { error: @organization.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @organization.update(organization_params)
      else
        render json: { error: @organization.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @organization.destroy
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
