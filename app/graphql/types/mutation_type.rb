# frozen_string_literal: true

Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'

  field :authenticate, Types::AuthenticationType do
    description 'Sign in user with given credentials'

    argument :email,    !types.String
    argument :password, !types.String

    resolve lambda{ |_obj, args, _ctx|
      result = AuthenticateUserService.perform(args[:email], args[:password])
      if result.success?
        OpenStruct.new({ token: result.payload, errors: nil })
      else
        OpenStruct.new({ token: nil, errors: result.payload })
      end
    }
  end

  field :createCategory, Types::CategoryType do
    description 'Create category'

    argument :orgId,    !types.ID
    argument :category, !Types::CategoryInputType

    resolve lambda{ |_obj, args, ctx|
      organization = ctx[:current_user].organizations.find(args[:orgId])
      category = organization.categories.build(args[:category].to_h)
      return category if category.save

      return GraphQL::ExecutionError.new(
        'Invalid record',
        options: { validationErrors: category.errors }
      )
    }
  end

  field :updateCategory, Types::CategoryType do
    description 'Update category'

    argument :id,       !types.ID
    argument :category, !Types::CategoryInputType

    resolve lambda{ |_obj, args, _ctx|
      category = Category.find(args[:id])
      return category if category.update(args[:category].to_h)

      return GraphQL::ExecutionError.new(
        'Invalid record',
        options: { validationErrors: category.errors }
      )
    }
  end

  field :deleteCategory, Types::CategoryType do
    description 'Delete category'

    argument :id, !types.ID

    resolve lambda{ |_obj, args, _ctx|
      category = Category.find(args[:id])
      return category if category.destroy

      return GraphQL::ExecutionError.new(
        'Invalid record',
        options: { validationErrors: category.errors }
      )
    }
  end
end
