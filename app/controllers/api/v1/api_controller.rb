module Api::V1
  class ApiController < Api::V1::BaseController

    def pundit_user
      current_user
    end

  end
end
