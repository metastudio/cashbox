class UserPolicy < ApplicationPolicy
  def update_profile?
    record_is_member?
  end

  def update?
    record_is_member?
  end

  def destroy?
    record_is_member?
  end

  private

  def record_is_member?
    @record.id == @member.id
  end
end
