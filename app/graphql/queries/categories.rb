# frozen_string_literal: true

class Queries::Categories < Queries::BaseQuery
  type [Types::Category], null: false
  description 'Categories for given organization'

  argument :org_id, ID,                  required: true
  argument :type,   Types::CategoryType, required: false

  def resolve(args)
    org = current_user.organizations.find(args[:org_id])
    scope = org.categories
    scope = scope.where(type: args[:type]) if args[:type].present?
    scope.order(:name)
  end
end
