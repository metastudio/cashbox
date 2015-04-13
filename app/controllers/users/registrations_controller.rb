class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :authenticate_scope!, only: [:edit, :update, :destroy,
    :update_profile]

  def create_user_from_invitation
    @user = User.new(sign_up_params)
    @invitation = Invitation.active.find_by_token(params[:token])
    @user.email = @invitation.email
    if @user.save
      sign_in @user
      redirect_to accept_invitation_path(token: @invitation.token)
    else
      render template: "invitations/accept"
    end
  end

  def update_profile
    if resource.update_without_password(update_profile_params)
      set_flash_message :notice, :updated if is_flashing_format?
      redirect_to user_profile_path
    else
      render :edit
    end
  end

  protected
    def after_update_path_for(resource)
      user_profile_path
    end

  private
    def update_profile_params
      params.require(resource_name).permit(:full_name, profile_attributes: [:phone_number])
    end
end
