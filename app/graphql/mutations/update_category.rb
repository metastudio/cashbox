# frozen_string_literal: true

class Mutations::UpdateCategory < Mutations::BaseMutation
  description 'Update a category'

  argument :id,       ID,                       required: true
  argument :category, Types::CategoryInputType, required: true

  field :category, Types::CategoryType, null: false, description: 'Updated category'

  def resolve(id:, category:)
    c = Category.where(organization_id: current_user.organization_ids).find(id)

    if c.update(category.to_h)
      { category: c }
    else
      raise GraphQL::ExecutionError.new(
        'Invalid record',
        options: { validationErrors: c.errors }
      )
    end
  end
end
