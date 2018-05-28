# frozen_string_literal: true

class Types::QueryType < Types::BaseObjectType
  graphql_name 'Query'
  description 'The query root of this schema'

  field :organization, resolver: Queries::Organization
  field :user_organizations, resolver: Queries::UserOrganizations

  field :categories, resolver: Queries::Categories
  field :category, resolver: Queries::Category
end
