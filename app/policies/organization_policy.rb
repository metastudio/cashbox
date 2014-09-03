class OrganizationPolicy < ApplicationPolicy

  def create?
    user.persisted?
  end

  def update?
    user.owner? || user.admin?
  end

  def destroy?
    user.owner?
  end
end
