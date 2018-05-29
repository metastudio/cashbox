# frozen_string_literal: true

class Types::Mutation < Types::BaseObject
  field :authenticate, mutation: Mutations::Authenticate

  field :create_category, mutation: Mutations::CreateCategory
  field :update_category, mutation: Mutations::UpdateCategory
  field :delete_category, mutation: Mutations::DeleteCategory
end
