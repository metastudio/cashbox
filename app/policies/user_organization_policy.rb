class UserOrganizationPolicy < ApplicationPolicy

  def update?
    if user.params[:user_organization] && user.params[:user_organization][:role] == 'owner'
      return false unless user.owner?
    end

    user.owner? || (user.admin? && record.role != 'owner')
  end

end
