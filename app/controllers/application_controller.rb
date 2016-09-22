class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  include Pundit

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_organization
  helper_method :current_member

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def current_organization
    return nil unless signed_in?
    @current_organization ||= current_user.organizations.find_by_id(session[:current_organization_id]) if session[:current_organization_id]
    @current_organization ||= current_user.organizations.first
  end

  def current_member
    @current_member ||= current_user.members.find_by(organization: current_organization) if current_organization
  end

  def require_organization
    unless current_organization
      flash.keep
      redirect_to new_organization_path, alert: "You don't have any organization. Create a new one."
    else
      unless request.xhr?
        organization = OrganizationWizzard.new(current_organization)
        if current_member.owner_or_admin? && organization.not_ready?
          flash.keep
          step = organization.step
          current_id = current_organization.id
          redirect_to send("#{step}_organization_path", current_id)
        end
      end
    end
  end

  def update_last_viewed_at
    current_member.update(last_visited_at: Time.current) if current_member
  end

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def pundit_user
    current_member
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, profile_attributes: [:phone_number, :avatar]])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name])
  end
end
