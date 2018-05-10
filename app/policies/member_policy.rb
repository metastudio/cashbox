class MemberPolicy < ApplicationPolicy
  def show?
    owner_or_admin_with_access? || record.id == member.id
  end

  def update?
    if member.params[:member] && member.params[:member][:role] == 'owner'
      return false unless member.owner?
    end

    owner_or_admin_with_access?
  end

  def update_last_viewed_at?
    owner_or_admin_with_access? || record.id == member.id
  end

  def destroy?
    owner_or_admin_with_access? && record.id != member.id
  end
end
