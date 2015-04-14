class OrganizationPolicy < ApplicationPolicy
  def initialize(member, record)
    @member = member.user.members.find_by(organization: record) if record
    @record = record
  end

  def edit?
    member.owner? || member.admin?
  end

  def update?
    member.owner? || member.admin?
  end

  def destroy?
    member.owner? || member.admin?
  end
end
