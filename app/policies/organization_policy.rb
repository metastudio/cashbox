class OrganizationPolicy < ApplicationPolicy

  def create?
    user.persisted?
  end

  def update?
    user.owner_in?(record) || user.admin_in?(record)
  end

  def destroy?
    user.owner_in?(record)
  end
end
