# frozen_string_literal: true

Types::OrganizationType = GraphQL::ObjectType.define do
  name 'Organization'

  field :id,              !types.ID
  field :name,            !types.String
  field :defaultCurrency, types.String,         property: :default_currency
  field :createdAt,       !Types::DateTimeType, property: :created_at
  field :updatedAt,       !Types::DateTimeType, property: :updated_at
  field :categories,      types[Types::CategoryType]
end
