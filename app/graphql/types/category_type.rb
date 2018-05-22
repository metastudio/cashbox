# frozen_string_literal: true

Types::CategoryType = GraphQL::ObjectType.define do
  name 'Category'

  field :id,              !types.ID
  field :organization_id, types.ID
  field :type,            !types.String
  field :name,            !types.String
  field :system,          !types.Boolean
  field :created_at,      !Types::DateTimeType
  field :updated_at,      !Types::DateTimeType
  field :deleted_at,      Types::DateTimeType
end
