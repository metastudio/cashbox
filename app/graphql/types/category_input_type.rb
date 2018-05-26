# frozen_string_literal: true

Types::CategoryInputType = GraphQL::InputObjectType.define do
  name 'CategoryInput'

  argument :type, types.String
  argument :name, types.String
end
