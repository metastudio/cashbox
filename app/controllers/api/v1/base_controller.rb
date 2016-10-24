module Api::V1
  class BaseController < ::ApplicationController
    include Knock::Authenticable

    class AuthorizationError < StandardError; end

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!
    before_action :authenticate

    respond_to :json

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from AuthorizationError, with: :unauthorized
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def unauthorized
      render json: {}, status: :unauthorized
    end

    def user_not_authorized
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end

    def not_found
      render json: {}, status: :not_found
    end

    def currencies
      render json: Dictionaries.currencies
    end

    resource_description do
      api_version '1'
      short 'Cashbox API - v1'
      formats ['json']
      error 404, 'Not Found'
      description 'Cashbox API'
    end
  end
end
