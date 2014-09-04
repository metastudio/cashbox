class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include Pundit

  before_filter :authenticate_user!

  helper_method :current_organization
  helper_method :current_user_organization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def current_organization
    return nil unless signed_in?
    @current_organization ||= current_user.organizations.find(session[:current_organization_id]) if session[:current_organization_id]
    @current_organization ||= current_user.organizations.first
  end

  def current_user_organization
    @current_user_organization ||= current_user.user_organizations.find_by(organization: current_organization) if current_organization
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
    current_user_organization.present? ? current_user_organization : current_user
  end
end
