# frozen_string_literal: true

Types::CategoryType = GraphQL::ObjectType.define do
  name 'Category'

  field :id,             !types.ID
  field :organizationId, types.ID, property: :organization_id
  field :type,           !types.String
  field :name,           !types.String
  field :system,         !types.Boolean
  field :createdAt,      !Types::DateTimeType, property: :created_at
  field :updatedAt,      !Types::DateTimeType, property: :updated_at
  field :deletedAt,      Types::DateTimeType, property: :deleted_at
end
