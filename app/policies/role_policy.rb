class RolePolicy < ApplicationPolicy

  def destroy?
    owner? || (admin? && !record.owner?)
  end

  def show?
    owner? || admin?
  end

  def update?
    owner? || (admin? && !record.owner?)
  end

  def create?
    owner? || (admin? && !record.owner?)
  end



  class Scope < Scope
    def resolve
      scope
    end
  end

  private

  def owner?
    user.owner_in?(record.organization)
  end

  def admin?
    user.admin_in?(record.organization)
  end
end
