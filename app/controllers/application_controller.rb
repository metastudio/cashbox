class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include Pundit

  before_filter :authenticate_user!
  before_filter :configure_permitted_parameters, if: :devise_controller?

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
    end
  end

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def pundit_user
    current_member
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) << [:full_name, profile_attributes: [:phone_number, :avatar]]
    devise_parameter_sanitizer.for(:sign_up) << [:full_name]
  end

  def update_last_viewed_at
    current_member.update_attribute(:last_visited_at, Time.now)
  end
end
