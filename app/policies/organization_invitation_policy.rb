class OrganizationInvitationPolicy < ApplicationPolicy
  def new?
    @invited_by.owner_or_admin?
  end

  def index?
    @invited_by.owner_or_admin?
  end

  def create?
    owner_or_admin_with_access?
  end

  def destroy?
    owner_or_admin_with_access?
  end

  def resend?
    owner_or_admin_with_access?
  end

  protected

  def owner_or_admin_with_access?
    (@invited_by.admin? && record.role != 'owner') || @invited_by.owner?
  end
end
