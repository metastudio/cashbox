# frozen_string_literal: true

class Types::AuthTokenType < GraphQL::Schema::Object
  graphql_name 'AuthToken'

  field :jwt, String, null: false, method: :jwt
end
