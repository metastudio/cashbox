# frozen_string_literal: true

class Types::Category < Types::BaseObject
  description 'Transaction category'

  field :id, ID, null: false

  field :organization_id, ID,                  null: false
  field :type,            Types::CategoryType, null: false
  field :name,            String,              null: false
  field :system,          Boolean,             null: false

  field :created_at, Types::DateTime, null: false
  field :updated_at, Types::DateTime, null: false
  field :deleted_at, Types::DateTime, null: true
end
