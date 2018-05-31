# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      before_action :authorize_user, only: %i[update destroy update_profile]

      def_param_group :update_profile do
        param :user, Hash do
          param :full_name, String
          param :profile_attributes, Hash do
            param :phone_number, String
          end
        end
      end

      def_param_group :update_account do
        param :user, Hash do
          param :email, String
          param :current_password, String
          param :password, String
          param :password_confirmation, String
        end
      end

      api :GET, '/users/current', 'Return current user'
      def current
        @user = current_user
      end

      api(
        :PUT,
        '/users/:id/update_profile',
        'Update full name, phone number or unsubscribe attribute for user'
      )
      param_group :update_profile
      def update_profile
        if @user.update_without_password(update_profile_params)
          render :current
        else
          render json: NestedErrors.unflatten(@user.errors), status: :unprocessable_entity
        end
      end

      api :PUT, '/users/:id', 'Return updated user'
      param_group :update_account
      def update
        if @user.update_with_password(update_account_params)
          render :current
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      api :DELETE, '/users/:id', 'Destroy User with this id if its you'
      def destroy
        @user.destroy
      end

      private

      def update_profile_params
        params.fetch(:user, {}).permit(
          :full_name,
          profile_attributes: [:phone_number],
          unsubscribe_attributes: [:active]
        )
      end

      def update_account_params
        params.fetch(:user, {}).permit(
          :email,
          :password,
          :password_confirmation,
          :current_password
        )
      end

      def authorize_user
        @user = User.find(params[:id])
        authorize @user
      end
    end
  end
end
