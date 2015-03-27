class CustomerPolicy < ApplicationPolicy

  def edit?
    member.owner? || member.admin?
  end

  def destroy?
    member.owner? || member.admin?
  end
end
