module Api::V1
  class ApiController < Api::V1::BaseController

    def pundit_user
      current_user
    end

    def current_organization
      @current_organization ||= current_user.organizations.find(params[:organization_id])
    end

  end
end
