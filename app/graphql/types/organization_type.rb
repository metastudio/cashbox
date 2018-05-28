# frozen_string_literal: true

class Types::OrganizationType < Types::BaseObjectType
  graphql_name 'Organization'

  field :id, ID, null: false

  field :name,             String, null: false
  field :default_currency, String, null: true

  field :created_at, Types::DateTimeType, null: false
  field :updated_at, Types::DateTimeType, null: false
end
