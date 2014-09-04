class MemberPolicy < ApplicationPolicy

  def update?
    if member.params[:member] && member.params[:member][:role] == 'owner'
      return false unless member.owner?
    end

    member.owner? || (member.admin? && record.role != 'owner')
  end

end
