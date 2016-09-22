module Api::V1
  class OrganizationController < ApiController

    def current_organization
      @current_organization ||= current_user.organizations.find(params[:organization_id])
    end

  end
end
