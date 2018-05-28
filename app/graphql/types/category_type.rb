# frozen_string_literal: true

class Types::CategoryType < Types::BaseObjectType
  graphql_name 'Category'
  description 'Transaction category'

  field :id, ID, null: false

  field :organization_id, ID,                      null: false
  field :type,            Types::CategoryTypeType, null: false
  field :name,            String,                  null: false
  field :system,          Boolean,                 null: false

  field :created_at, Types::DateTimeType, null: false
  field :updated_at, Types::DateTimeType, null: false
  field :deleted_at, Types::DateTimeType, null: true
end
