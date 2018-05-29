# frozen_string_literal: true

class Mutations::BaseMutation < GraphQL::Schema::Mutation
  def current_user
    context[:current_user].presence || (raise User::AuthenticationRequiredError)
  end
end
