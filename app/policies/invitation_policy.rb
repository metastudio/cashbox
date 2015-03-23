class InvitationPolicy < ApplicationPolicy
  def index?
    owner_or_admin_for_record?
  end

  def create?
    owner_or_admin_for_record?
  end

  private
  def owner_or_admin_for_record?
    (member.admin? && record.role != 'owner') || member.owner?
  end
end
