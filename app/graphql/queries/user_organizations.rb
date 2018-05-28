# frozen_string_literal: true

class Queries::UserOrganizations < Queries::BaseQuery
  type [Types::Organization], null: false
  description 'Organizations associated with current user'

  def resolve
    return [] unless current_user

    current_user.organizations.sort(:name)
  end
end
