class InvitationPolicy < ApplicationPolicy
  def new?
    member.owner_or_admin?
  end

  def index?
    member.owner_or_admin?
  end

  def create?
    (member.admin? && record.role != 'owner') || member.owner?
  end

  def destroy?
    (member.admin? && record.role != 'owner') || member.owner?
  end

  def resend?
    (member.admin? && record.role != 'owner') || member.owner?
  end
end
