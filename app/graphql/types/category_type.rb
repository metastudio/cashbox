# frozen_string_literal: true

class Types::CategoryType < GraphQL::Schema::Object
  graphql_name 'Category'
  description 'List of categories'

  field :id,              ID,                  null: false
  field :organization_id, ID,                  null: false
  field :type,            String,              null: false
  field :name,            String,              null: false
  field :system,          Boolean,             null: false
  field :created_at,      Types::DateTimeType, null: false
  field :updated_at,      Types::DateTimeType, null: false
  field :deleted_at,      Types::DateTimeType, null: true
end
