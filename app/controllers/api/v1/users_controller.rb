module Api::V1
  class UsersController < ApiController

    api :GET, '/users/current', 'Show current user'
    def current
    end

  end
end
