# frozen_string_literal: true

module Api::V1
  class AuthTokenController < BaseController
    skip_before_action :authenticate_user
    before_action :authenticate_by_credentials!

    api :POST, '/auth_token', 'Create auth token'
    param :auth, Hash do
      param :email, String, desc: 'Email for auth', required: true
      param :password, String, desc: 'Password', required: true
    end
    def create
      render json: { jwt: @auth_token.token }, status: :created
    end

    private

    def authenticate_by_credentials!
      result = AuthenticateUserService.perform(auth_params[:email], auth_params[:password])

      if result.success?
        @auth_token = result.payload
      else
        render json: { error: result.payload }, status: :unauthorized
      end
    end

    def auth_params
      params.require(:auth).permit :email, :password
    end
  end
end
