# frozen_string_literal: true

require './lib/nested_errors.rb'

module Api::V1
  class BaseController < ::ApplicationController
    include Knock::Authenticable
    include NestedErrors

    class AuthorizationError < StandardError; end

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!
    before_action :authenticate_user

    respond_to :json

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from AuthorizationError, with: :unauthorized
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def unauthorized
      render json: {}, status: :unauthorized
    end

    def user_not_authorized
      render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden
    end

    def not_found
      render json: {}, status: :not_found
    end

    resource_description do
      api_version '1'
      short 'Cashbox API - v1'
      formats ['json']
      error 404, 'Not Found'
      description 'Cashbox API'
    end

    private

    # overwrite current_user added by devise with
    # a method for knock (gem would add this if it were not already defined)
    # https://github.com/nsarno/knock/issues/220
    def current_user
      @current_user ||=
        begin
          Knock::AuthToken.new(token: @auth_token.token).entity_for(User)
        rescue
          nil
        end
    end

    def pundit_user
      current_user
    end

    def pagination_info(collection)
      {
        current:  collection.current_page,
        previous: collection.prev_page,
        next:     collection.next_page,
        per_page: collection.limit_value,
        pages:    collection.total_pages,
        count:    collection.total_count
      }
    end
    helper_method :pagination_info
  end
end
