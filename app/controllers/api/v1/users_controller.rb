module Api::V1
  class UsersController < ApiController

    def show
      render json: current_user
    end

  end
end
