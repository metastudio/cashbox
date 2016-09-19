module Api::V1
  class UsersController < ApiController

    def current
      render partial: 'user', locals: { user: current_user }
    end

  end
end
