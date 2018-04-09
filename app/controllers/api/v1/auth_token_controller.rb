module Api::V1
  class AuthTokenController < BaseController
    skip_before_action :authenticate
    before_action :authenticate_by_credentials!

    api :POST, '/auth_token', 'Create auth token'
    param :auth, Hash do
      param :email, String, desc: 'Email for auth', required: true
      param :password, String, desc: 'Password', required: true
    end
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
        raise Api::V1::BaseController::AuthorizationError
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
