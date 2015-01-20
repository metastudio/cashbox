class User::RegistrationsController < Devise::RegistrationsController
  def create_user
    @user = User.new(user_params)
    @user.email = @invitation.email

    if @user.save
      redirect_to accept_invitation_path(token: @invitation.token)
    else
      render template: "invitations_controller/accept"
    end
  end
end
