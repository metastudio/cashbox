# frozen_string_literal: true

class Types::QueryType < Types::BaseObjectType
  graphql_name 'Query'
  description 'The query root of this schema'

  field :organization, Types::OrganizationType, null: true do
    argument :id, ID, required: true
    description 'Find an Organization by ID'
  end
  field :user_organizations, [Types::OrganizationType], null: false do
    description 'Find user\'s organizations'
  end
  field :categories, [Types::CategoryType], null: false do
    description 'Find categories for given organization'
    argument :org_id, ID,                      required: true
    argument :type,   Types::CategoryTypeType, required: false
  end
  field :category, Types::CategoryType, null: true do
    argument :id, ID, required: true
    description 'Find category by ID'
  end

  def organization(id:)
    return nil unless current_user

    context[:current_user].organizations.find(id)
  end

  def user_organizations
    return [] unless current_user

    context[:current_user].organizations.sort(:name)
  end

  def category(id:)
    return nil unless current_user

    Category.where(organization_id: current_user.organization_ids).find(id)
  end

  def categories(args)
    scope = Category.where(organization_id: current_user.organization_ids & [args[:org_id].to_i])
    scope.where(type: args[:type]) if args[:type].present?
    scope
  end
end
