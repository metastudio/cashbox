# frozen_string_literal: true

class Mutations::UpdateCategory < Mutations::BaseMutation
  description 'Update a category'

  argument :id,       ID,                   required: true
  argument :category, Types::CategoryInput, required: true

  field :category, Types::Category, null: false, description: 'Updated category'

  def resolve(id:, category:)
    c = Category.where(organization_id: current_user.organization_ids).find(id)

    if c.update(category.to_h)
      { category: c }
    else
      context.add_error GraphQL::ExecutionError.new(
        'Invalid record',
        options: { 'validationErrors' => c.errors.as_json }
      )
    end
  end
end
