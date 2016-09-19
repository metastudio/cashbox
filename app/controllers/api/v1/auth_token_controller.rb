module Api::V1
  class AuthTokenController < ApiController
    skip_before_action :authenticate
    before_action :authenticate_by_credentials!

    def create
      render json: { jwt: auth_token.token }, status: :created
    end

    private

    def authenticate_by_credentials!
      if user && user.authenticate(auth_params[:password])
        if !user.locked?
          return
        else
          render json: { error: I18n.t("devise.failure.locked") }, status: :unauthorized
        end
      else
        raise Api::BaseController::AuthorizationError
      end
    end

    def auth_token
      Knock::AuthToken.new payload: { sub: user.id }
    end

    def user
      User.find_by Knock.handle_attr => auth_params[Knock.handle_attr]
    end

    def auth_params
      params.require(:auth).permit Knock.handle_attr, :password
    end
  end
end
