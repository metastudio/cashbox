# frozen_string_literal: true

class Queries::BaseQuery < GraphQL::Schema::Resolver
  def current_user
    context[:current_user].presence || (raise User::AuthenticationRequiredError)
  end
end
