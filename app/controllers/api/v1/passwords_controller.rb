module Api::V1
  class PasswordsController < Devise::PasswordsController
    respond_to :json

    api :POST, '/users/password', 'Reset password'
    def create
      @user = User.send_reset_password_instructions(reset_password_params)

      if successfully_sent?(@user)
        render json: {}, status: :ok
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    api :PUT, '/users/password', 'Update password'
    def update
      @user = User.reset_password_by_token(update_password_params)

      if @user.errors.empty?
        render json: {}, status: :ok
      else
        set_minimum_password_length
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def reset_password_params
      params.require(:user).permit(:email)
    end

    def update_password_params
      params.require(:user).permit(:password, :password_confirmation, :reset_password_token)
    end
  end
end
