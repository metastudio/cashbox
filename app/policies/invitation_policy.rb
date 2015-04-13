class InvitationPolicy < ApplicationPolicy
  def create?
    (member.admin? && record.role != 'owner') || member.owner?
  end
end
