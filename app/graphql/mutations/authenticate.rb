# frozen_string_literal: true

class Mutations::Authenticate < Mutations::BaseMutation
  description 'Sign in a user with the given credentials'

  argument :email,    String, required: true
  argument :password, String, required: true

  field :token, Types::AuthToken, null: false

  def resolve(email:, password:)
    result = AuthenticateUserService.perform(email, password)

    if result.success?
      { token: result.payload }
    else
      context.add_error(GraphQL::ExecutionError.new(result.payload))
    end
  end
end
