class OrganizationPolicy < ApplicationPolicy
  def initialize(member, record)
    if member.is_a? User
      @member = member.members.find_by(organization: record) if record
    else
      @member = member.user.members.find_by(organization: record) if record
    end
    @record = record
  end

  def edit?
    @member.owner? || @member.admin?
  end

  def update?
    @member.owner? || @member.admin?
  end

  def destroy?
    @member.owner? || @member.admin?
  end

  def total_balances?
    @member
  end
end
