# frozen_string_literal: true

Types::OrganizationType = GraphQL::ObjectType.define do
  name 'Organization'

  field :id,              !types.ID
  field :name,            !types.String
  field :defaultCurrency, types.String,         property: :default_currency
  field :createdAt,       !Types::DateTimeType, property: :created_at
  field :updatedAt,       !Types::DateTimeType, property: :updated_at
  field :categories,      !types[Types::CategoryType.graphql_definition]

  field :category, Types::CategoryType do
    argument :id, !types.ID
    description 'Find a Category by ID within organization'
    resolve lambda{ |obj, args, _ctx|
      return nil if obj.blank?
      obj.categories.find(args[:id])
    }
  end
end
