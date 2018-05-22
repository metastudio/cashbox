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
end
