# frozen_string_literal: true

class Api::V1::ApiController < Api::V1::BaseController
  def pundit_user
    current_member
  end

  def current_organization
    @current_organization ||= current_user.organizations.find(params[:organization_id])
  end

  def current_member
    @current_member ||= current_user.members.find_by(organization: current_organization) if current_organization
  end

  def pagination_info(collection)
    {
      current:  collection.current_page,
      previous: collection.prev_page,
      next:     collection.next_page,
      per_page: collection.limit_value,
      pages:    collection.max_pages,
      count:    collection.total_count
    }
  end
  helper_method :pagination_info
end
