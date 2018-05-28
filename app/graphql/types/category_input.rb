# frozen_string_literal: true

class Types::CategoryInput < GraphQL::Schema::InputObject
  argument :type, Types::CategoryType, required: false
  argument :name, String,              required: false
end
