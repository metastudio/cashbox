# frozen_string_literal: true

class Types::CategoryInputType < GraphQL::Schema::InputObject
  graphql_name 'CategoryInput'

  argument :type, Types::CategoryTypeType, required: false
  argument :name, String,                  required: false
end
