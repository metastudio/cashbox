# frozen_string_literal: true

class Mutations::DeleteCategory < Mutations::BaseMutation
  description 'Delete a category'

  argument :id, ID, required: true

  field :category, Types::CategoryType, null: false, description: 'Deleted category'

  def resolve(id:)
    c = Category.where(organization_id: current_user.organization_ids).find(id)

    if c.destroy
      { category: c }
    else
      raise GraphQL::ExecutionError.new(
        'Invalid record',
        options: { validationErrors: c.errors }
      )
    end
  end
end
