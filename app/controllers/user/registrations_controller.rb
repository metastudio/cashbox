class User::RegistrationsController < Devise::RegistrationsController

  def update_profile
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    resource_updated = resource.update_without_password(account_update_params)

    if resource_updated
      set_flash_message :notice, :updated if is_flashing_format?
      sign_in resource_name, resource, bypass: true
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def after_update_path_for(resource)
    user_profile_path
  end
end
