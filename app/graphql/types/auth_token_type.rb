# frozen_string_literal: true

Types::AuthTokenType = GraphQL::ObjectType.define do
  name 'AuthToken'

  field :jwt, !types.String, property: :token
end
