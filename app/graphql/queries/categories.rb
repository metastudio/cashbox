# frozen_string_literal: true

class Queries::Categories < Queries::BaseQuery
  type [Types::Category], null: false
  description 'Categories for given organization'

  argument :org_id, ID,                  required: true
  argument :type,   Types::CategoryType, required: false

  def resolve(args)
    scope = Category.where(organization_id: current_user.organization_ids & [args[:org_id].to_i])
    scope.where(type: args[:type]) if args[:type].present?
    scope
  end
end
