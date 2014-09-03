class UserOrganizationPolicy < ApplicationPolicy

  def update?
    user.owner? || (user.admin? && record.role != 'owner')
  end

end
