module Api::V1
  class ApiController < Api::V1::BaseController

    def pundit_user
      current_user
    end

    def current_organization
      @current_organization ||= current_user.organizations.find_by_id(params[:organization_id]) if params[:organization_id].present?
      @current_organization ||= current_user.organizations.first
    end

    def current_member
      @current_member ||= current_user.members.find_by(organization: current_organization) if current_organization
    end
  end
end
