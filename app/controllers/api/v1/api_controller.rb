module Api::V1
  class ApiController < Api::BaseController

    def current_member
      @current_member ||= current_user.current_member
    end

    def pundit_user
      current_member.present? ? current_member : current_user
    end

  end
end
