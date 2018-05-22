# frozen_string_literal: true

Types::AuthenticationType = GraphQL::ObjectType.define do
  name 'Authentication'

  field :token, Types::AuthTokenType
  field :errors, types.String
end
