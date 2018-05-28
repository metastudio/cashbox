# frozen_string_literal: true

class Queries::Category < Queries::BaseQuery
  type Types::CategoryType, null: false
  description 'Find a Category by ID'

  argument :id, ID, required: true

  def resolve(id:)
    return nil unless current_user

    Category.where(organization_id: current_user.organization_ids).find(id)
  end
end
