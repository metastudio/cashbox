class MemberPolicy < ApplicationPolicy

  def update?
    if member.params[:member] && member.params[:member][:role] == 'owner'
      return false unless member.owner?
    end

    owner_or_admin_with_access?
  end

  def destroy?
    owner_or_admin_with_access? && record.id != member.id
  end

end
