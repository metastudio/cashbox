# frozen_string_literal: true

class Mutations::Authenticate < Mutations::BaseMutation
  description 'Sign in a user with the given credentials'

  argument :email,    String, required: true
  argument :password, String, required: true

  field :token, Types::AuthTokenType, null: false

  def resolve(email:, password:)
    result = AuthenticateUserService.perform(email, password)

    return GraphQL::ExecutionError.new(result.payload) unless result.success?

    OpenStruct.new({ token: result.payload })
  end
end
