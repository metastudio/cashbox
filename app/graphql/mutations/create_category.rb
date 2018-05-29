# frozen_string_literal: true

class Mutations::CreateCategory < Mutations::BaseMutation
  description 'Create a category'

  argument :org_id,   ID,                   required: true
  argument :category, Types::CategoryInput, required: true

  field :category, Types::Category, null: false, description: 'Created category'

  def resolve(org_id:, category:)
    organization = current_user.organizations.find(org_id)
    c = organization.categories.build(category.to_h)
    if c.save
      { category: c }
    else
      context.add_error GraphQL::ExecutionError.new(
        'Invalid record',
        options: { 'validationErrors' => c.errors.as_json }
      )
    end
  end
end
