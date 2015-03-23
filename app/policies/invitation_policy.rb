class InvitationPolicy < ApplicationPolicy
  def owner_or_admin_for_record?
    (member.admin? && record.role != 'owner') || member.owner?
  end
end
