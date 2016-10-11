module Api::V1
  class PasswordsController < Devise::PasswordsController

    api :POST, '/users/password', 'Reset password'
    def create
      @user = User.find_by_email(user_params[:email])
      if @user.present?
        @user.send_reset_password_instructions
        render json: {}, status: :ok
      else
        render json: { errors: 'Not found' }, status: :not_found
      end
    end

    private

    def user_params
      params.require(:user).permit(:email)
    end

  end
end
