# frozen_string_literal: true

class Types::BaseObjectType < GraphQL::Schema::Object
  def current_user
    context[:current_user]
  end
end
