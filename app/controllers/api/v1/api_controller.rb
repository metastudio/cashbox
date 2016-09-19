module Api::V1
  class ApiController < Api::BaseController

    def pundit_user
      current_user
    end

  end
end
