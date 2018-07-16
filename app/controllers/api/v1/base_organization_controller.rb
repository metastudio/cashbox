# frozen_string_literal: true

class Api::V1::BaseOrganizationController < Api::V1::BaseController
  def pundit_user
    current_member
  end

  def current_organization
    @current_organization ||= current_user.organizations.find(params[:organization_id])
  end

  def current_member
    @current_member ||= current_user.members.find_by(organization: current_organization) if current_organization
  end
end
