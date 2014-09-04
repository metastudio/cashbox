class OrganizationPolicy < ApplicationPolicy

  def update?
    member.owner? || member.admin?
  end

  def destroy?
    member.owner?
  end
end
