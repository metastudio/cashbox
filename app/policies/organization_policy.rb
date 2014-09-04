class OrganizationPolicy < ApplicationPolicy

  def update?
    user.owner? || user.admin?
  end

  def destroy?
    user.owner?
  end
end
