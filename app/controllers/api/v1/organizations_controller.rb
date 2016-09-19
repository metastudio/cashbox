module Api::V1
  class OrganizationsController < ApiController
    before_action :set_organization, only: [:show, :update, :destroy]
    before_action :authorize_organization, only: [:show, :update, :destroy]

    def index
      render json: current_user.organizations
    end

    def show
      render json: @organization
    end

    def create
      @organization = current_account.organizations.build organization_params

      if @organization.save
        Member.create(user: current_user, organization: @organization, role: 'owner')
        render json: @organization, status: :created, location: @organization
      else
        render json: @organization.errors, status: :unprocessable_entity
      end
    end

    def update
      if @organization.update(organization_params)
        render json: @organization
      else
        render json: @organization.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @organization.destroy
      render nothing: true, status: :no_content
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
