# frozen_string_literal: true

class Queries::Organization < Queries::BaseQuery
  type Types::OrganizationType, null: false
  description 'Find an Organization by ID'

  argument :id, ID, required: true

  def resolve(id:)
    return nil unless current_user

    current_user.organizations.find(id)
  end
end
