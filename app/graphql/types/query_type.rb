# frozen_string_literal: true

Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'The query root of this schema'

  field :category do
    type Types::CategoryType
    argument :id, !types.ID
    description 'Find a Category by ID'
    resolve ->(_obj, args, _ctx) { Category.find(args[:id]) }
  end
end
