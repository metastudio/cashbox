class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!

  private

  def current_organization
    @current_organization ||= current_user.organizations.find(session[:current_organization_id]) if session[:current_organization_id]
  end

  def require_organization
    unless current_organization
      redirect_to organizations_path
    end
  end
end
