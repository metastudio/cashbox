class OrganizationPolicy < ApplicationPolicy

  def edit?
    member.owner? || member.admin?
  end

  def delete?
    member.owner? || member.admin?
  end

  def update?
    member.owner? || member.admin?
  end

  def destroy?
    member.owner? || member.admin?
  end
end
