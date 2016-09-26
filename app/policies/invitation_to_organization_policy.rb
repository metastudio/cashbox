class InvitationToOrganizationPolicy < ApplicationPolicy
  def new?
    member.owner_or_admin?
  end

  def index?
    member.owner_or_admin?
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
end
