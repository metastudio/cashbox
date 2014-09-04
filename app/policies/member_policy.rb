class MemberPolicy < ApplicationPolicy

  def update?
    if user.params[:member] && user.params[:member][:role] == 'owner'
      return false unless user.owner?
    end

    user.owner? || (user.admin? && record.role != 'owner')
  end

end
