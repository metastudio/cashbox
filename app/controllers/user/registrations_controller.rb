class User::RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :authenticate_scope!, only: [:edit, :update, :destroy,
    :update_profile]

  def update_profile
    if resource.update_without_password(update_profile_params)
      set_flash_message :notice, :updated if is_flashing_format?
      redirect_to user_profile_path
    else
      render :edit
    end
  end

  def after_update_path_for(resource)
    user_profile_path
  end

  private
    def update_profile_params
      params.require(resource_name).permit(:full_name, profile_attributes: [:phone_number])
    end
end
