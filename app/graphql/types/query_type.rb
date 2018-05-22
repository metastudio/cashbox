# frozen_string_literal: true

Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'The query root of this schema'

  field :organization, Types::OrganizationType do
    argument :id, !types.ID
    description 'Find an Organization by ID'
    resolve lambda{ |_obj, args, ctx|
      return nil if ctx[:current_user].blank?
      ctx[:current_user].organizations.find(args[:id])
    }
  end
  field :userOrganizations do
    type ->{ !types[Types::OrganizationType] }
    resolve lambda { |_obj, args, ctx|
      return [] if ctx[:current_user].blank?

      q = ctx[:current_user].organizations.search(args)
      q.sorts = 'created_at' if q.sorts.blank?
      q.result
    }
  end
end
